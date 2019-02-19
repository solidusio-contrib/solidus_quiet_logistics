# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusQuietLogistics::Inbound::Document::ShipmentOrderCancelReady do
  describe '#process' do
    subject(:document) do
      described_class.new(
        shipment_number: shipment.number,
        cancellation_status: cancellation_status,
        date_cancelled: date_cancelled,
      )
    end

    let(:date_cancelled) { Time.now }
    let(:first_shipment_order_cancel_mailer) { instance_double('ActionMailer::Delivery') }
    let(:second_shipment_order_cancel_mailer) { instance_double('ActionMailer::Delivery') }

    let(:order) { create(:completed_order_with_totals) }
    let(:shipment) { order.shipments.first }

    before do
      create(:shipment, order: order)
      order.reload
    end

    context 'when the cancellation was successful' do
      let(:cancellation_status) { 'SUCCESS' }

      before do
        order.shipments.each do |shipment|
          shipment.update!(pushed: true, ql_cancellation_sent: Time.now)
        end

        allow(SolidusQuietLogistics::Inbound::ShipmentOrderCancelMailer).to receive(:successful_cancellation)
          .with(shipment, recipient: shipment.order.email)
          .and_return(first_shipment_order_cancel_mailer)

        allow(SolidusQuietLogistics::Inbound::ShipmentOrderCancelMailer).to receive(:successful_cancellation)
          .with(shipment)
          .and_return(second_shipment_order_cancel_mailer)
      end

      it 'updates shipment ql_cancellation_date timestamp and cancel the shipment' do
        expect(first_shipment_order_cancel_mailer).to receive(:deliver_later)
        expect(second_shipment_order_cancel_mailer).to receive(:deliver_later)

        document.process

        shipment.reload
        expect(shipment.ql_cancellation_date.utc.to_s).to eq(date_cancelled.utc.to_s)
        expect(shipment.state).to eq('canceled')
        expect(shipment.order.state).to eq('complete')
      end

      context 'when all the shipments were canceled' do
        before { order.shipments.last.cancel! }

        it 'cancels the order' do
          expect(first_shipment_order_cancel_mailer).to receive(:deliver_later)
          expect(second_shipment_order_cancel_mailer).to receive(:deliver_later)

          document.process

          shipment.reload
          expect(shipment.order.state).to eq('canceled')
        end
      end
    end

    context 'when the cancellation fails' do
      let(:cancellation_status) { 'FAIL' }

      before do
        allow(SolidusQuietLogistics::Inbound::ShipmentOrderCancelMailer).to receive(:failed_cancellation)
          .with(shipment, recipient: shipment.order.email)
          .and_return(first_shipment_order_cancel_mailer)

        allow(SolidusQuietLogistics::Inbound::ShipmentOrderCancelMailer).to receive(:failed_cancellation)
          .with(shipment)
          .and_return(second_shipment_order_cancel_mailer)
      end

      it 'sends the email and clear the ql_cancellation_sent timestamp' do
        expect(first_shipment_order_cancel_mailer).to receive(:deliver_later)
        expect(second_shipment_order_cancel_mailer).to receive(:deliver_later)

        document.process

        expect(shipment.ql_cancellation_sent).to eq(nil)
      end
    end
  end
end
