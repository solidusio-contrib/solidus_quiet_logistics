# frozen_string_literal: true

module SolidusQuietLogistics
  module Inbound
    class Document < SolidusQuietLogistics::Document
      class ShipmentOrderCancelReady < SolidusQuietLogistics::Inbound::Document
        class << self
          def from_xml(body)
            nokogiri = Nokogiri::XML(body)

            new(
              shipment_number: nokogiri.xpath('//@OrderNumber').first.text,
              cancellation_status: nokogiri.xpath('//@Status').first.value,
              date_cancelled: nokogiri.xpath('//@DateCancelled').first.value,
            )
          end
        end

        attr_reader :shipment_number, :cancellation_status, :date_cancelled,
          :shipment

        def initialize(shipment_number:, cancellation_status:, date_cancelled: Time.now)
          @shipment_number = shipment_number
          @date_cancelled = date_cancelled
          @cancellation_status = cancellation_status
          @shipment = Spree::Shipment.find_by(number: shipment_number)
        end

        def process
          return if shipment&.canceled?

          if cancellation_status == 'SUCCESS'
            successful_cancellation
          else
            failed_cancellation
          end
        end

        private

        def failed_cancellation
          shipment.update(ql_cancellation_sent: nil)

          SolidusQuietLogistics::Inbound::ShipmentOrderCancelMailer
            .failed_cancellation(shipment, recipient: shipment.order.email)
            .deliver_later
          SolidusQuietLogistics::Inbound::ShipmentOrderCancelMailer
            .failed_cancellation(shipment).deliver_later
        end

        def successful_cancellation
          shipment.cancel!
          shipment.update!(ql_cancellation_date: date_cancelled)

          shipment.order.cancel! if shipment.order.shipments.all?(&:canceled?)

          SolidusQuietLogistics::Inbound::ShipmentOrderCancelMailer
            .successful_cancellation(shipment, recipient: shipment.order.email)
            .deliver_later
          SolidusQuietLogistics::Inbound::ShipmentOrderCancelMailer
            .successful_cancellation(shipment).deliver_later
        end
      end
    end
  end
end
