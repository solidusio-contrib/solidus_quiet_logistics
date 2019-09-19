# frozen_string_literal: true

module SolidusQuietLogistics
  module Inbound
    class Document < SolidusQuietLogistics::Document
      class ShipmentOrderResult < SolidusQuietLogistics::Inbound::Document
        class CartonLine
          attr_reader :number, :quantity, :item_number

          class << self
            def from_xml_element(line)
              new(
                number: line['Line'],
                quantity: line['Quantity'],
                item_number: line['ItemNumber'],
              )
            end
          end

          def initialize(number:, quantity:, item_number:)
            @number = number.to_i
            @quantity = quantity.to_i
            @item_number = item_number
          end
        end

        class Carton
          attr_reader :carton_id, :tracking_number, :lines

          class << self
            def from_xml_element(carton)
              new(
                carton_id: carton['CartonId'],
                tracking_number: carton['TrackingId'],
                lines: carton.css('Content').map { |line| CartonLine.from_xml_element(line) },
              )
            end
          end

          def initialize(carton_id:, tracking_number:, lines:)
            @carton_id = carton_id
            @tracking_number = tracking_number
            @lines = lines
          end

          def inventory_units_for(shipment)
            lines.flat_map do |line|
              shipment
                .inventory_units
                .pre_shipment
                .joins(:variant)
                .where(spree_variants: { sku: line.item_number })
                .to_a
                .take(line.quantity)
            end
          end
        end

        class << self
          def from_xml(body)
            document = Nokogiri::XML(body)
            element = document.css('SOResult').first

            new(
              shipment_number: element['OrderNumber'],
              cartons: extract_cartons(element),
              shipped_at: Time.zone.parse(element['DateShipped']),
            )
          end

          private

          def extract_cartons(element)
            element.css('Carton').map { |carton| Carton.from_xml_element(carton) }
          end
        end

        attr_reader :shipment_number, :cartons, :shipped_at

        def initialize(shipment_number:, cartons:, shipped_at:)
          @shipment_number = shipment_number
          @cartons = cartons
          @shipped_at = shipped_at
        end

        def process
          shipment = Spree::Shipment.find_by(number: shipment_number)
          return unless shipment

          shipped_cartons = ActiveRecord::Base.transaction do
            shipped_cartons = cartons.map do |carton|
              inventory_units = carton.inventory_units_for(shipment)
              next if inventory_units.empty?

              # If the shipment was shipped by QL, it's because all items were in stock, so we need
              # to fill any inventory units that were backordered due to our own inventory levels
              # being out of sync with QL.
              inventory_units.select(&:backordered?).each(&:fill_backorder!)

              shipment.order.shipping.ship(
                inventory_units: inventory_units,
                stock_location: shipment.stock_location,
                address: shipment.order.ship_address,
                shipping_method: shipment.shipping_method,
                shipped_at: shipped_at,
                external_number: carton.carton_id,
                tracking_number: carton.tracking_number,
                suppress_mailer: true,
              )
            end.compact

            shipment.update!(tracking: cartons.map(&:tracking_number).join(','))

            # Needed in order to update the order's shipment_state. Otherwise, the updater is called
            # with a collection of old shipments whose states are still "pending".
            shipment.order.reload.update!
            shipped_cartons
          end

          send_shipment_emails(shipped_cartons)
        end

        def send_shipment_emails(shipped_cartons)
          return if shipped_cartons.blank?

          orders = shipped_cartons.flat_map(&:orders).uniq

          orders.each do |order|
            Spree::Config.carton_shipped_email_class
                         .multi_shipped_email(order: order, cartons: shipped_cartons)
                         .deliver_later
          end
        end
      end
    end
  end
end
