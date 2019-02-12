# frozen_string_literal: true

module SolidusQuietLogistics
  module Outbound
    class Document < SolidusQuietLogistics::Document
      class ShipmentOrderCancel < SolidusQuietLogistics::Outbound::Document
        attr_reader :shipment

        class << self
          def document_type
            'ShipmentOrderCancel'
          end
        end

        def initialize(shipment)
          @shipment = shipment
        end

        def to_xml
          Nokogiri::XML::Builder.new(encoding: 'utf-8') do |xml|
            xml.ShipmentOrderCancel(
              xmlns: 'http://schemas.quietlogistics.com/V2/ShipmentOrderCancel.xsd',
              'xmlns:xsi': 'http://www.w3.org/2001/XMLSchema-instance',
              'xsi:schemaLocation': 'http://schemas.quietlogistics.com/V2/ShipmentOrderCancel.xsd schema.xsd',
              ClientId: SolidusQuietLogistics.configuration.client_id,
              BusinessUnit: SolidusQuietLogistics.configuration.business_unit,
              OrderNumber: shipment.number,
            )
          end.to_xml
        end

        def process
          super

          shipment.update(ql_cancellation_sent: Time.zone.now)
        end

        private

        def validate_context
          fail NotPushedError unless shipment.pushed?
          fail CancellationAlreadySent if shipment.ql_cancellation_sent.present?
        end

        def document_name
          [
            SolidusQuietLogistics.configuration.client_id,
            self.class.document_type,
            shipment.number,
            shipment.created_at.strftime('%Y%m%d'),
            shipment.created_at.strftime('%H%M%S'),
          ].join('_').concat('.xml')
        end

        NotPushedError = Class.new(SolidusQuietLogistics::Outbound::Error::ServiceError)
        CancellationAlreadySent = Class.new(SolidusQuietLogistics::Outbound::Error::ServiceError)
      end
    end
  end
end
