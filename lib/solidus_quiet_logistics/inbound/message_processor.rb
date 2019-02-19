# frozen_string_literal: true

module SolidusQuietLogistics
  module Inbound
    class MessageProcessor
      DOCUMENT_CLASSES = {
        'ShipmentOrderResult' => Document::ShipmentOrderResult,
        'ShipmentOrderCancelReady' => Document::ShipmentOrderCancelReady,
        # 'InventorySummaryReady' => Document::InventorySummaryReady,
        # 'RMAResultDocument' => Document::RMAResultDocument,
        # 'ProductConfigurationRequest' => Document::ProductConfigurationRequest,
        # 'PurchaseOrderStartReceipt' => Document::PurchaseOrderStartReceipt,
        # 'PurchaseOrderReceipt' => Document::PurchaseOrderReceipt,
        # 'ShipmentOrderCancelReady' => Document::ShipmentOrderCancelReady,
        # 'ShipmentOrderManifest' => Document::ShipmentOrderManifest,
        # 'ShipmentOrderCartonManifest' => Document::ShipmentOrderCartonManifest,
        # 'ShipmentOrderTracking' => Document::ShipmentOrderTracking,
        # 'ShipmentOrderSummary' => Document::ShipmentOrderSummary,
      }.freeze

      class << self
        def process(message_body)
          message = SolidusQuietLogistics::Inbound::Message.from_xml(message_body)

          document_class_for(message).from_message(message).process
        end

        private

        def document_class_for(message)
          DOCUMENT_CLASSES[message.document_type] || fail(Error::UnhandledMessageError, message)
        end
      end
    end
  end
end
