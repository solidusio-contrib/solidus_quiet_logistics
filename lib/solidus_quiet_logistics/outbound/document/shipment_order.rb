# frozen_string_literal: true

module SolidusQuietLogistics
  module Outbound
    class Document < SolidusQuietLogistics::Document
      class ShipmentOrder < SolidusQuietLogistics::Outbound::Document
        attr_reader :shipment

        class << self
          def document_type
            'ShipmentOrder'
          end
        end

        def initialize(shipment)
          @shipment = shipment
        end

        def to_xml
          Nokogiri::XML::Builder.new(encoding: 'utf-8') do |xml|
            xml.ShipOrderDocument(xmlns: 'http://schemas.quietlogistics.com/V2/ShipmentOrder.xsd') do |ship_order|
              ship_order.ClientID SolidusQuietLogistics.configuration.client_id
              ship_order.BusinessUnit SolidusQuietLogistics.configuration.business_unit

              ship_order.OrderHeader(
                OrderNumber: shipment.number,
                OrderType: 'SO',
                CustomerPO: shipment.number,
                VIPCustomer: false,
                StoreDelivery: false,
                Gift: gift_message.present?,
                OrderPriority: shipment.shipping_method.priority,
                OrderDate: shipment.order.created_at.strftime('%Y-%m-%dT%H:%M:%SZ'),
              ) do |order_header|
                order_header.Comments gift_message if gift_message.present?

                order_header.ShipMode(
                  Carrier: shipment.shipping_method.carrier,
                  ServiceLevel: shipment.shipping_method.service_level,
                )

                order_header.ShipTo(
                  Contact: address_name_for(shipment.order.ship_address),
                  Address1: shipment.order.ship_address.address1,
                  Address2: shipment.order.ship_address.address2,
                  City: shipment.order.ship_address.city,
                  State: shipment.order.ship_address.state.name,
                  PostalCode: shipment.order.ship_address.zipcode,
                  Country: shipment.order.ship_address.country.iso,
                  Phone: shipment.order.ship_address.phone,
                  Email: shipment.order.email,
                )

                order_header.BillTo(
                  Contact: address_name_for(shipment.order.bill_address),
                  Address1: shipment.order.bill_address.address1,
                  Address2: shipment.order.bill_address.address2,
                  City: shipment.order.bill_address.city,
                  State: shipment.order.bill_address.state.name,
                  PostalCode: shipment.order.bill_address.zipcode,
                  Country: shipment.order.bill_address.country.iso,
                  Phone: shipment.order.bill_address.phone,
                  Email: shipment.order.email,
                )

                order_header.ShipSpecialService ship_special_service if ship_special_service.present?

                order_header.ValueAddedService(
                  Service: 'string',
                  ServiceType: 'string',
                )
              end

              shipment.line_items.each.with_index(1) do |line_item, index|
                ship_order.OrderDetails(
                  Line: index,
                  ItemNumber: line_item.sku,
                  QuantityOrdered: quantity(line_item),
                  QuantityToShip: quantity(line_item),
                  Price: line_item.price,
                  UOM: 'EA',
                )
              end
            end
          end.to_xml
        end

        def process
          super

          shipment.pushed = true
          shipment.save!
        end

        private

        def validate_context
          fail Error::AlreadyPushedError, shipment if shipment.pushed?
        end

        def document_name
          [
            SolidusQuietLogistics.configuration.client_id,
            self.class.document_type,
            shipment.number,
            shipment.order.created_at.strftime('%Y%m%d'),
            shipment.order.created_at.strftime('%H%M%S'),
          ].join('_').concat('.xml')
        end

        def quantity(line_item)
          @shipment.inventory_units.where(variant_id: line_item.variant_id).count
        end

        def ship_special_service
          SolidusQuietLogistics.configuration.order_special_service_amount&.call(shipment)
        end

        def gift_message
          SolidusQuietLogistics.configuration.order_gift_message&.call(shipment.order)
        end

        def address_name_for(address)
          address.respond_to?(:name) ? address.name : address.full_name
        end
      end
    end
  end
end
