# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusQuietLogistics::Outbound::Document::ShipmentOrderCancel do
  include_context 'quiet_logistics_outbound_document'

  subject(:document) { described_class.new(shipment) }

  let(:shipment) { create(:shipment, pushed: true) }

  describe '#process' do
    it 'changes the ql_cancellation_sent timestamp' do
      document.process

      expect(shipment.ql_cancellation_sent.present?).to eq(true)
    end

    context 'when shipment wasn\'t pushed' do
      before { shipment.update(pushed: false) }

      it 'fails with invalid shipping method error' do
        expect { document.process }.to raise_error(SolidusQuietLogistics::Outbound::Document::ShipmentOrderCancel::NotPushedError)
      end
    end

    context 'when shipment cancellation already sent' do
      before { shipment.update(ql_cancellation_sent: Time.now) }

      it 'fails with shipment cancellation already sent' do
        expect { document.process }.to raise_error(SolidusQuietLogistics::Outbound::Document::ShipmentOrderCancel::CancellationAlreadySent)
      end
    end
  end
end
