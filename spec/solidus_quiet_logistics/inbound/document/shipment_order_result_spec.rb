# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusQuietLogistics::Inbound::Document::ShipmentOrderResult do
  describe '.from_xml' do
    subject(:document) { described_class.from_xml(xml) }

    let(:xml) { read_ql_document(:shipment_order_result) }

    it 'parses the shipment number' do
      expect(document.shipment_number).to eq('1234567890')
    end

    it 'parses the cartons' do
      expect(document.cartons.map(&:tracking_number)).to match_array(%w[40000000000 40000000001])
      expect(document.cartons.map(&:carton_id)).to match_array(%w[S12345678901 S12345678902])
    end

    it 'parses the carton lines' do
      expect(document.cartons.flat_map(&:lines).map(&:number)).to match_array([1, 1, 2, 2])
      expect(document.cartons.flat_map(&:lines).map(&:quantity)).to match_array([1, 1, 2, 1])
    end
  end

  describe '#process' do
    subject(:document) do
      described_class.new(
        shipment_number: shipment_number,
        shipped_at: shipped_at,
        cartons: cartons,
      )
    end

    let(:shipment_number) { '1234567890' }
    let(:shipped_at) { Time.zone.now }
    let(:cartons) do
      [
        described_class::Carton.new(
          tracking_number: '40000000000',
          carton_id: 'S12345678901',
          lines: [
            described_class::CartonLine.new(
              number: 1,
              quantity: 1,
              item_number: 'PROD-1',
            ),
          ],
        ),
        described_class::Carton.new(
          tracking_number: '40000000001',
          carton_id: 'S12345678902',
          lines: [
            described_class::CartonLine.new(
              number: 2,
              quantity: 2,
              item_number: 'PROD-2',
            ),
          ],
        ),
      ]
    end

    before do
      allow(Spree::Shipment).to receive(:find_by)
        .with(number: shipment_number)
        .and_return(shipment)
    end

    context 'when the shipment is not found' do
      let(:shipment) { nil }

      it 'ignores the document' do
        expect { subject.process }.not_to raise_error
      end
    end

    context 'when the shipment is found' do
      let(:shipment) { FactoryBot.build_stubbed(:shipment) }

      let(:line_item1) { FactoryBot.build_stubbed(:line_item, variant: FactoryBot.build_stubbed(:variant, sku: 'PROD-1')) }
      let(:line_item2) { FactoryBot.build_stubbed(:line_item, variant: FactoryBot.build_stubbed(:variant, sku: 'PROD-2')) }

      let(:inventory_unit1) { instance_spy('Spree::InventoryUnit', backordered?: false) }
      let(:inventory_unit2) { instance_spy('Spree::InventoryUnit', backordered?: true) }
      let(:inventory_unit3) { instance_spy('Spree::InventoryUnit', backordered?: false) }

      let(:multi_carton_mailer) { instance_spy('ActionMailer::Delivery') }
      let(:shipped_carton) { instance_spy('Spree::Carton') }

      context 'when the result document has line in the cartons' do
        before do
          allow(shipment.order).to receive(:shipping)
            .and_return(instance_spy('Spree::OrderShipping'))

          allow(shipment.order.shipping).to receive(:ship)
            .and_return(shipped_carton)

          allow(shipped_carton).to receive(:orders)
            .and_return([shipment.order])

          allow(shipment).to receive(:line_items)
            .and_return([line_item1, line_item2])

          allow(shipment.inventory_units).to receive(:pre_shipment)
            .and_return(shipment.inventory_units)

          allow(shipment.inventory_units).to receive(:joins)
            .and_return(shipment.inventory_units)

          allow(shipment.inventory_units).to receive(:where)
            .with(spree_variants: { sku: line_item1.variant.sku })
            .and_return([inventory_unit1])

          allow(shipment.inventory_units).to receive(:where)
            .with(spree_variants: { sku: line_item2.variant.sku })
            .and_return([inventory_unit2, inventory_unit3])

          allow(shipment).to receive(:update_attributes!)

          allow(shipment.order).to receive(:reload)
            .and_return(shipment.order)

          allow(shipment.order).to receive(:update!)

          allow(Spree::Config.carton_shipped_email_class).to receive(:multi_shipped_email)
            .and_return(multi_carton_mailer)
        end

        it 'creates the cartons' do
          subject.process

          expect(shipment.order.shipping).to have_received(:ship).with(
            inventory_units: [inventory_unit1],
            stock_location: shipment.stock_location,
            address: shipment.order.ship_address,
            shipping_method: shipment.shipping_method,
            shipped_at: shipped_at,
            external_number: 'S12345678901',
            tracking_number: '40000000000',
            suppress_mailer: true,
          ).once

          expect(shipment.order.shipping).to have_received(:ship).with(
            inventory_units: [inventory_unit2, inventory_unit3],
            stock_location: shipment.stock_location,
            address: shipment.order.ship_address,
            shipping_method: shipment.shipping_method,
            shipped_at: shipped_at,
            external_number: 'S12345678902',
            tracking_number: '40000000001',
            suppress_mailer: true,
          ).once
        end

        it 'updates the tracking number' do
          subject.process

          expect(shipment).to have_received(:update_attributes!)
            .with(tracking: cartons.map(&:tracking_number).join(','))
            .once
        end

        it 'fills backordered inventory units' do
          subject.process

          expect(inventory_unit2).to have_received(:fill_backorder!).once
        end

        it 'updates the order' do
          subject.process

          expect(shipment.order).to have_received(:update!).once
        end

        it 'sends one email for all cartons shipped' do
          subject.process

          expect(multi_carton_mailer).to have_received(:deliver_later).once
        end
      end

      context 'when the result document does not have line in the cartons' do
        let(:cartons) do
          [
            described_class::Carton.new(
              tracking_number: '40000000000',
              carton_id: 'S12345678901',
              lines: [],
            ),
          ]
        end

        it 'does not raise RecordInvalid exception' do
          expect { subject.process }.not_to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end
  end
end
