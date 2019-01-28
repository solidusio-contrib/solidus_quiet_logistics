# frozen_string_literal: true

module SolidusQuietLogistics
  module Outbound
    class PushShipmentOrderDocumentJob < ActiveJob::Base
      queue_as :default

      def perform(element_to_push)
        case element_to_push
        when Spree::Shipment
          perform_shipment(element_to_push)
        when Spree::Order
          perform_order(element_to_push)
        else
          raise ArgumentError, 'This job accept only shipment or order as argument'
        end
      end

      private

      def perform_order(order)
        order.shipments.each do |shipment|
          perform_shipment(shipment)
        end
      end

      def perform_shipment(shipment)
        return unless SolidusQuietLogistics.configuration.enabled&.call(shipment.order)

        SolidusQuietLogistics::Outbound::Document::ShipmentOrder.new(shipment).process
      rescue SolidusQuietLogistics::Outbound::Error::AlreadyPushedError
        Rails.logger.info "QL shipment order already sent for shipment #{shipment.id}"
      end
    end
  end
end
