# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'QL inbound - inventory summary' do
  include_context 'quiet_logistics_inbound_integration' do
    let(:document_type) { :inventory_summary_ready }
  end

  let!(:variant) { create(:variant, sku: 'TEST-QL') }

  let!(:default_stock_location) { create(:stock_location, default: true) }

  let!(:stock_item) do
    default_stock_location.stock_item_or_create(variant).tap do |stock_item|
      stock_item.set_count_on_hand(2)
    end
  end

  it 'processes the message correctly' do
    subject.call
    stock_item.reload

    expect(stock_item.count_on_hand).to eq(5)
  end
end
