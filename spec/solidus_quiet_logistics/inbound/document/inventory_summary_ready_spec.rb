# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusQuietLogistics::Inbound::Document::InventorySummaryReady do
  describe '.from_xml' do
    subject(:document) { described_class.from_xml(xml) }

    let(:xml) { read_ql_document(:inventory_summary_ready) }

    it 'parses the inventory items' do
      expect(parse_items(document)).to eq(
        'TEST-QL' => {
          available: 5,
          received: 1,
          allocated: 3,
        },
        '12346' => {
          available: 2,
          received: 0,
          allocated: 0,
        },
      )
    end

    def parse_items(document)
      Hash[document.items.map do |item|
        [item.sku, available: item.available, allocated: item.allocated, received: item.received]
      end]
    end
  end

  describe '#process' do
    subject(:document) do
      described_class.new(
        items: [
          described_class::Item.new(sku: 'VALID-SKU', available: 5, received: 1, allocated: 3),
          described_class::Item.new(sku: 'INVALID-SKU', available: 2, received: 3, allocated: 7),
        ],
      )
    end

    let(:stock_item) { instance_spy('Spree::StockItem') }

    before do
      variant = instance_double('Spree::Variant')
      allow(Spree::Variant).to receive(:find_by)
        .with(sku: 'VALID-SKU')
        .and_return(variant)

      allow(Spree::Variant).to receive(:find_by)
        .with(sku: 'INVALID-SKU')
        .and_return(nil)

      default_stock_location = instance_double('Spree::StockLocation')
      allow(Spree::StockLocation).to receive(:order_default)
        .and_return([default_stock_location])

      allow(default_stock_location).to receive(:stock_item_or_create)
        .with(variant)
        .and_return(stock_item)
    end

    it 'adjusts the on-hand counts of stock items for existing SKUs' do
      document.process

      expect(stock_item).to have_received(:set_count_on_hand)
        .with(5)
        .once
    end
  end
end
