# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spree::RefundReason do
  describe '.return_processing_reason' do
    context 'when the return processing reason doesn\'t exist' do
      it 'creates return processing reason' do
        described_class.return_processing_reason

        expect(described_class.count).to eq(1)
        expect(described_class.first.name).to eq('Return processing')
      end
    end

    context 'when return processing reason exist' do
      let!(:refund_reason) { create(:refund_reason, name: 'Return processing', mutable: false) }

      it 'returns it' do
        described_class.return_processing_reason

        expect(described_class.first).to eq(refund_reason)
      end
    end
  end
end
