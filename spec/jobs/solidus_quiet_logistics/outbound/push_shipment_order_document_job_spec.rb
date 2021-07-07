# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusQuietLogistics::Outbound::PushShipmentOrderDocumentJob do
  context 'when perform is called with an order' do
    subject { -> { described_class.perform_now(order) } }

    let(:order) { create(:order_with_line_items) }

    let(:first_shipment_order) { instance_spy(SolidusQuietLogistics::Outbound::Document::ShipmentOrder) }
    let(:second_shipment_order) { instance_spy(SolidusQuietLogistics::Outbound::Document::ShipmentOrder) }

    before do
      if Rails.gem_version > Gem::Version.new(6.1)
        create(:shipment, order: order)
      else
        order.shipments << create(:shipment, order: order)
      end

      allow(SolidusQuietLogistics::Outbound::Document::ShipmentOrder).to receive(:new)
        .with(order.shipments.first)
        .and_return(first_shipment_order)

      allow(SolidusQuietLogistics::Outbound::Document::ShipmentOrder).to receive(:new)
        .with(order.shipments.last)
        .and_return(second_shipment_order)
    end

    it 'processes all the order shipments' do
      subject.call

      expect(first_shipment_order).to have_received(:process)
      expect(second_shipment_order).to have_received(:process)
    end
  end

  context 'when perform is called with a shipment' do
    subject { -> { described_class.perform_now(shipment) } }

    let(:order) { create(:order_with_line_items) }

    let(:shipment) { order.shipments.first }
    let(:shipment_order) { instance_spy(SolidusQuietLogistics::Outbound::Document::ShipmentOrder) }

    before do
      allow(SolidusQuietLogistics::Outbound::Document::ShipmentOrder).to receive(:new)
        .with(shipment).and_return(shipment_order)
    end

    it 'processes the shipment' do
      subject.call

      expect(shipment_order).to have_received(:process)
    end
  end

  context 'when perform is called with a bad argument' do
    subject { described_class.perform_now(bad_argument) }

    let(:bad_argument) { 'Bad argument' }

    it 'raises an argument error exception' do
      expect { subject }.to raise_error(ArgumentError)
    end
  end
end
