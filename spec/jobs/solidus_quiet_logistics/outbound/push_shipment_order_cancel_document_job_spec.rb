# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusQuietLogistics::Outbound::PushShipmentOrderCancelDocumentJob do
  subject { -> { described_class.perform_now(shipment) } }

  let(:order) { create(:order_with_line_items) }
  let(:shipment) { order.shipments.first }

  let(:shipment_order_cancel) do
    instance_spy('SolidusQuietLogistics::Outbound::Document::ShipmentOrderCancel')
  end

  before do
    allow(SolidusQuietLogistics::Outbound::Document::ShipmentOrderCancel).to receive(:new)
      .with(shipment)
      .and_return(shipment_order_cancel)
  end

  it 'processes the order' do
    subject.call

    expect(shipment_order_cancel).to have_received(:process)
  end
end
