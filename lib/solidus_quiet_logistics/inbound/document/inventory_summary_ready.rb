# frozen_string_literal: true

module SolidusQuietLogistics
  module Inbound
    class Document < SolidusQuietLogistics::Document
      class InventorySummaryReady < SolidusQuietLogistics::Inbound::Document
        class Item
          attr_accessor :sku, :available, :received, :allocated

          def initialize(sku:, available: 0, received: 0, allocated: 0)
            @sku = sku
            @available = available
            @received = received
            @allocated = allocated
          end

          def adjust_count(count_type, delta)
            send("#{count_type}=", send(count_type) + delta)
          end
        end

        class << self
          def from_xml(body)
            nokogiri = Nokogiri::XML(body)

            items = nokogiri.css('Inventory').map do |inventory|
              Item.new(sku: inventory['ItemNumber']).tap do |item|
                inventory.css('ItemStatus').each do |item_status|
                  status = {
                    avail: :available,
                    received: :received,
                    alloc: :allocated,
                  }[item_status['Status'].downcase.to_sym]

                  next unless status

                  item.adjust_count(status, item_status['Quantity'].to_i)
                end
              end
            end

            new(items: items)
          end
        end

        attr_reader :items

        def initialize(items:)
          @items = items
        end

        def process
          stock_location = ::Spree::StockLocation.order_default.first

          items.each do |item|
            variant = ::Spree::Variant.find_by(sku: item.sku)
            next unless variant

            stock_item = stock_location.stock_item_or_create(variant)
            stock_item.set_count_on_hand([item.available, 0].max)
          end
        end
      end
    end
  end
end
