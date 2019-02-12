# frozen_string_literal: true

module SolidusQuietLogistics
  module Outbound
    class PushShipmentOrderCancelDocumentJob < ActiveJob::Base
      queue_as :default

      def perform(shipment)
        return unless SolidusQuietLogistics.configuration.enabled&.call(shipment.order)

        SolidusQuietLogistics::Outbound::Document::ShipmentOrderCancel.new(shipment).process
      rescue SolidusQuietLogistics::Outbound::Document::ShipmentOrderCancel::CancellationAlreadySent
        Rails.logger.info "QL cancellation already sent for shipment #{shipment.id}"
      end
    end
  end
end
