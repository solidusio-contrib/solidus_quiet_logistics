# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusQuietLogistics::Outbound::Document::RMADocument do
  include_context 'quiet_logistics_outbound_document'

  subject(:document) { described_class.new(return_authorization) }

  describe '#process' do
    let(:return_authorization) { create(:return_authorization) }

    it 'changes the pushed flag to true and adds the ql_rma_sent timestamp' do
      document.process

      expect(return_authorization.pushed).to eq(true)
      return_authorization.return_items.map(&:inventory_units).each do |inventory_unit|
        expect(inventory_unit.ql_rma_sent.present?).to eq(true)
      end
    end

    context 'when the return authorization was already pushed' do
      before { return_authorization.update(pushed: true) }

      it 'fails with return authorization already pushed' do
        expect { document.process }.to raise_error(SolidusQuietLogistics::Outbound::Error::AlreadyPushedError)
      end
    end
  end

  describe '#to_xml' do
    let(:return_authorization) { create(:return_authorization) }

    let(:first_variant) { create(:variant) }
    let(:second_variant) { create(:variant) }

    let(:return_reason) { create(:return_reason) }

    let!(:first_return_item) do
      create(
        :return_item,
        inventory_unit: create(:inventory_unit, variant: first_variant),
        return_authorization: return_authorization,
        return_reason: return_reason,
      )
    end

    let!(:second_return_item) do
      create(
        :return_item,
        inventory_unit: create(:inventory_unit, variant: first_variant),
        return_authorization: return_authorization,
        return_reason: return_reason,
      )
    end

    let!(:third_return_item) do
      create(
        :return_item,
        inventory_unit: create(:inventory_unit, variant: first_variant),
        return_authorization: return_authorization,
        return_reason: create(:return_reason),
      )
    end

    let!(:fourth_return_item) do
      create(
        :return_item,
        inventory_unit: create(:inventory_unit, variant: second_variant),
        return_authorization: return_authorization,
        return_reason: return_reason,
      )
    end

    before { return_authorization.reload }

    it 'groups line by variant and return reason' do
      nokogiri = Nokogiri::XML(document.to_xml)
      expect(nokogiri.css('Line').count).to eq(3)
    end

    it 'numbers the lines progressively' do
      nokogiri = Nokogiri::XML(document.to_xml)
      expect(nokogiri.css('Line').map { |line| line['LineNo'].to_i }).to eq([1, 2, 3])
    end
  end
end
