# frozen_string_literal: true

module SolidusQuietLogistics
  module Inbound
    class Document < SolidusQuietLogistics::Document
      class RmaResultDocument < SolidusQuietLogistics::Inbound::Document
        class RmaItem
          attr_reader :line, :number, :quantity, :product_status, :order_number,
            :notes

          class << self
            def from_element(line)
              new(
                line: line['LineNo'],
                number: line['ItemNumber'],
                quantity: line['Quantity'],
                product_status: line['ProductStatus'],
                order_number: line['OrderNumber'],
                notes: line['Notes'],
              )
            end
          end

          def initialize(line:, number:, quantity:, product_status:,
            order_number:, notes: '')

            @line = line
            @number = number
            @quantity = quantity
            @product_status = product_status
            @order_number = order_number
            @notes = notes
          end

          def correct?
            correct_statuses = SolidusQuietLogistics.configuration&.rma_correct_product_statuses || []
            correct_statuses.any? { |status| status == product_status }
          end
        end

        class << self
          def from_xml(body)
            nokogiri = Nokogiri::XML(body)
            items = nokogiri.css('Line').map { |line| RmaItem.from_element(line) }

            new(
              rma_number: nokogiri.xpath('//@RMANumber').first.text,
              rma_items: items,
            )
          end
        end

        attr_reader :return_authorization, :rma_items

        def initialize(rma_number:, rma_items: [])
          @return_authorization = Spree::ReturnAuthorization.find_by(number: rma_number)
          @rma_items = rma_items
        end

        def process
          return unless return_authorization

          correct_items = rma_items.select(&:correct?)
          incorrect_items = rma_items - correct_items

          refund_customer(correct_items)
          notify_support_team(incorrect_items)
        end

        private

        def return_authorization_items(return_items)
          return_items.flat_map do |item|
            return_authorization.return_items
              .where(acceptance_status: 'pending')
              .joins(inventory_unit: :variant)
              .where(spree_variants: { sku: item.number }).limit(item.quantity)
          end
        end

        def refund_customer(correct_items)
          return_items = return_authorization_items(correct_items)
          return if return_items.empty?

          customer_return = Spree::CustomerReturn.create!(
            stock_location: return_authorization.stock_location,
            return_items: return_items,
          )

          return_items.each do |return_item|
            return_item.receive
            return_item.inventory_unit.update!(ql_rma_received: Time.zone.now)
          end

          begin
            Spree::Reimbursement.create!(
              order: return_authorization.order,
              customer_return: customer_return,
              return_items: return_items,
            ).return_all(created_by: return_authorization.order.user)
          rescue Spree::Reimbursement::IncompleteReimbursementError => e
            Rails.logger.info e.message
          end
        end

        def notify_support_team(incorrect_items)
          return_items = return_authorization_items(incorrect_items)
          return if return_items.all?(&:blank?)

          return_items.each do |return_item|
            return_item.inventory_unit.update!(ql_rma_sent: nil)
          end

          SolidusQuietLogistics::Inbound::RmaMailer
            .failed_refund_to_customer(
              return_authorization,
              return_items,
            )
            .deliver_later

          SolidusQuietLogistics::Inbound::RmaMailer
            .failed_refund_to_support(
              return_authorization,
              return_items,
            )
            .deliver_later
        end
      end
    end
  end
end
