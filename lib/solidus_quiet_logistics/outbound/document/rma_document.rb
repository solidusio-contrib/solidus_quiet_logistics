# frozen_string_literal: true

module SolidusQuietLogistics
  module Outbound
    class Document < SolidusQuietLogistics::Document
      class RMADocument < SolidusQuietLogistics::Outbound::Document
        attr_reader :return_authorization

        class << self
          def document_type
            'RMADocument'
          end
        end

        def initialize(return_authorization)
          @return_authorization = return_authorization
        end

        def to_xml
          Nokogiri::XML::Builder.new(encoding: 'utf-8') do |xml|
            xml.RMADocument(
              xmlns: 'http://schemas.quietlogistics.com/V2/RMADocument.xsd',
              'xmlns:xsi': 'http://www.w3.org/2001/XMLSchema-instance',
              'xsi:schemaLocation': 'http://schemas.quietlogistics.com/V2/RMADocument.xsd schema.xsd',
            ) do |document|
              document.RMA(
                ClientID: SolidusQuietLogistics.configuration.client_id,
                BusinessUnit: SolidusQuietLogistics.configuration.business_unit,
                RMANumber: return_authorization.number,
              ) do |rma|
                # Solidus creates a return item per inventory unit,
                # but QL expects one item per variant/return reason combination.
                ql_return_lines.each do |return_line|
                  rma.Line(
                    LineNo: return_line[:line],
                    OrderNumber: return_line[:return_items].first.shipment.number,
                    ItemNumber: return_line[:variant].sku,
                    Quantity: return_line[:return_items].count,
                    SaleUOM: 'EA',
                    ReturnReason: return_line[:return_reason]&.name,
                    CustomerComment: return_authorization.memo,
                  )
                end
              end
            end
          end.to_xml
        end

        def process
          super

          return_authorization.update!(pushed: true)

          return_authorization.return_items.map(&:inventory_unit).each do |inventory_unit|
            inventory_unit.update!(ql_rma_sent: Time.zone.now)
          end
        end

        private

        def validate_context
          fail Error::AlreadyPushedError, return_authorization if return_authorization.pushed?
        end

        def document_name
          [
            SolidusQuietLogistics.configuration.client_id,
            self.class.document_type,
            return_authorization.number,
            return_authorization.created_at.strftime('%Y%m%d'),
            return_authorization.created_at.strftime('%H%M%S'),
          ].join('_').concat('.xml')
        end

        def ql_return_lines
          return_lines = []

          return_authorization.return_items.group_by(&:variant).flat_map do |variant, items|
            items.group_by(&:return_reason).each do |return_reason, return_items|
              return_lines << {
                line: (return_lines.any? ? return_lines.last[:line] + 1 : 1),
                variant: variant,
                return_reason: return_reason,
                return_items: return_items,
              }
            end
          end

          return_lines
        end
      end
    end
  end
end
