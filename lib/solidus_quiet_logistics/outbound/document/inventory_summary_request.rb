# frozen_string_literal: true

module SolidusQuietLogistics
  module Outbound
    class Document < SolidusQuietLogistics::Document
      class InventorySummaryRequest < SolidusQuietLogistics::Outbound::Document
        class << self
          def document_type
            'InventorySummaryRequest'
          end
        end

        def to_xml
          Nokogiri::XML::Builder.new(encoding: 'utf-8') do |xml|
            xml.InventorySummaryRequest(xmlns: 'http://schemas.quietlogistics.com/V2/InventorySummaryRequest.xsd') do |isr|
              isr.ClientID SolidusQuietLogistics.configuration.client_id
              isr.BusinessUnit SolidusQuietLogistics.configuration.business_unit
            end
          end.to_xml
        end

        private

        def document_name
          [
            SolidusQuietLogistics.configuration.client_id,
            self.class.document_type,
            SecureRandom.hex(4).upcase,
            Time.zone.now.strftime('%Y%m%d'),
            Time.zone.now.strftime('%H%M%S'),
          ].join('_').concat('.xml')
        end
      end
    end
  end
end
