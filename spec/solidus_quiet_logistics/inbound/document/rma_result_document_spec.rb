# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusQuietLogistics::Inbound::Document::RMAResultDocument do
  let(:correct_rma_dict) do
    {
      line: '1',
      number: '050-00400',
      quantity: '1',
      product_status: 'GOOD',
      order_number: 'R123456789-1',
      notes: 'This is a note',
    }
  end

  let(:damaged_rma_dict) do
    {
      line: '2',
      number: '050-00400',
      quantity: '2',
      product_status: 'DAMAGED',
      order_number: 'R123456789-1',
      notes: '',
    }
  end

  let(:incorrect_rma_dict) do
    {
      line: '3',
      number: '050-00400',
      quantity: '1',
      product_status: 'INCORRECT',
      order_number: 'R123456789-1',
      notes: '',
    }
  end

  describe '.from_xml' do
    subject(:document) { described_class.from_xml(xml) }

    let(:xml) { read_ql_document(:rma_result_document) }

    it 'parses the rma items' do
      expect(parse_items(document)).to match_array([correct_rma_dict, damaged_rma_dict, incorrect_rma_dict])
    end

    def parse_items(document)
      document.rma_items.map do |item|
        {
          line: item.line,
          number: item.number,
          quantity: item.quantity,
          product_status: item.product_status,
          order_number: item.order_number,
          notes: item.notes,
        }
      end
    end
  end

  describe '#process' do
    subject(:document) do
      described_class.new(
        rma_number: return_authorization_number,
        rma_items: [
          described_class::RMAItem.new(correct_rma_dict),
          described_class::RMAItem.new(damaged_rma_dict),
          described_class::RMAItem.new(incorrect_rma_dict),
        ],
      )
    end

    let(:order) { create(:shipped_order) }

    let(:return_authorization) { create(:return_authorization, order: order) }
    let(:return_authorization_number) { return_authorization.number }

    let(:variant) { create(:variant, sku: '050-00400') }

    let!(:good_return_item) do
      create(:return_item,
             inventory_unit: create(:inventory_unit, order: create(:order), state: 'shipped'),
             return_authorization: return_authorization,)
    end
    let!(:damaged_return_item) do
      create(:return_item,
             inventory_unit: create(:inventory_unit, order: create(:order), state: 'shipped'),
             return_authorization: return_authorization,)
    end
    let!(:incorrect_return_item) do
      create(:return_item,
             inventory_unit: create(:inventory_unit, order: create(:order), state: 'shipped'),
             return_authorization: return_authorization,)
    end

    let(:rma_document_to_customer_mailer) { instance_double('ActionMailer::Delivery') }
    let(:rma_document_to_suppport_mailer) { instance_double('ActionMailer::Delivery') }

    before do
      allow(SolidusQuietLogistics::Inbound::RMAMailer).to receive(:failed_refund_to_customer)
        .and_return(rma_document_to_customer_mailer)

      allow(SolidusQuietLogistics::Inbound::RMAMailer).to receive(:failed_refund_to_support)
        .and_return(rma_document_to_suppport_mailer)

      return_authorization.reload.return_items.map do |return_item|
        return_item.inventory_unit.update(variant: variant)
        return_item.shipment.update(order: order)
      end
    end

    it 'refunds the correct return items and sends an email to the support for the incorrect return items' do
      expect(rma_document_to_customer_mailer).to receive(:deliver_later)
      expect(rma_document_to_suppport_mailer).to receive(:deliver_later)

      document.process

      expect(order.reimbursements.first.reimbursement_status).to eq('reimbursed')
      expect(good_return_item.reload.reception_status).to eq('received')
      expect(damaged_return_item.reload.reception_status).to eq('received')
      expect(incorrect_return_item.reload.reception_status).to eq('awaiting')

      expect(good_return_item.inventory_unit.ql_rma_received).to be_present
      expect(damaged_return_item.inventory_unit.ql_rma_received).to be_present
      expect(incorrect_return_item.inventory_unit.ql_rma_sent).not_to be_present

      expect(return_authorization.customer_returns.uniq.count).to eq(1)
      expect(return_authorization.customer_returns.first.reimbursements.count).to eq(1)
    end

    context 'when rma_number is wrong' do
      let(:return_authorization_number) { 'Wrong rma number' }

      it 'doesn\'t refunt the return items and doesn\'t send the email to the support' do
        expect(rma_document_to_customer_mailer).not_to receive(:deliver_later)
        expect(rma_document_to_suppport_mailer).not_to receive(:deliver_later)

        document.process

        expect(order.reimbursements.count).to eq(0)
        expect(good_return_item.reload.reception_status).to eq('awaiting')
        expect(damaged_return_item.reload.reception_status).to eq('awaiting')
        expect(incorrect_return_item.reload.reception_status).to eq('awaiting')
      end
    end

    context 'when rma_items are all correct' do
      subject(:document) do
        described_class.new(
          rma_number: return_authorization_number,
          rma_items: [
            described_class::RMAItem.new(correct_rma_dict),
            described_class::RMAItem.new(damaged_rma_dict),
          ],
        )
      end

      it 'refunds the correct return items' do
        expect(rma_document_to_customer_mailer).not_to receive(:deliver_later)
        expect(rma_document_to_suppport_mailer).not_to receive(:deliver_later)

        document.process

        expect(order.reimbursements.first.reimbursement_status).to eq('reimbursed')
        expect(good_return_item.reload.reception_status).to eq('received')
        expect(damaged_return_item.reload.reception_status).to eq('received')
      end
    end

    context 'when rma_items are all incorrect' do
      subject(:document) do
        described_class.new(
          rma_number: return_authorization_number,
          rma_items: [
            described_class::RMAItem.new(incorrect_rma_dict),
          ],
        )
      end

      it 'does not refund any items' do
        expect(rma_document_to_customer_mailer).to receive(:deliver_later)
        expect(rma_document_to_suppport_mailer).to receive(:deliver_later)

        document.process

        expect(order.reimbursements.count).to eq(0)
      end
    end
  end
end
