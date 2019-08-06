# frozen_string_literal: true

module SolidusQuietLogistics
  module Inbound
    class MessageProcessor
      DOCUMENT_CLASSES = {
        'ShipmentOrderResult' => Document::ShipmentOrderResult,
        'ShipmentOrderCancelReady' => Document::ShipmentOrderCancelReady,
        'RMAResultDocument' => Document::RMAResultDocument,
        'InventorySummaryReady' => Document::InventorySummaryReady,
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

          ql_message = QlMessage.create!(
            document_name: message.document_name,
            document_type: message.document_type,
            document_body: message_body,
          )

          document_class_for(message).from_message(message).process

          ql_message.update!(success: true, processed_at: Time.now)
        end

        private

        def document_class_for(message)
          DOCUMENT_CLASSES[message.document_type] || fail(Error::UnhandledMessageError, message)
        end
      end
    end
  end
end
