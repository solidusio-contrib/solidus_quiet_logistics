# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusQuietLogistics::Inbound::ShipmentOrderCancelMailer, type: :mailer do
  let(:shipment) { create(:shipment) }
  let(:recipient) { shipment.order.email }
  let(:support_email) { 'support@email.com' }

  before do
    allow(SolidusQuietLogistics.configuration).to receive(:support_email)
      .and_return(support_email)
  end

  describe '.failed_cancellation' do
    context 'when recipient is defined' do
      let(:mail) { described_class.failed_cancellation(shipment, recipient: recipient) }

      it 'sends the email to the specified recipient' do
        expect(mail.to).to eq([recipient])
      end
    end

    context 'when recipient is not defined' do
      let(:mail) { described_class.failed_cancellation(shipment) }

      it 'sends the email to the support email' do
        expect(mail.to).to eq([support_email])
      end
    end
  end

  describe '.successful_cancellation' do
    context 'when recipient is defined' do
      let(:mail) { described_class.successful_cancellation(shipment, recipient: recipient) }

      it 'sends the email to the specified recipient' do
        expect(mail.to).to eq([recipient])
      end
    end

    context 'when recipient is not defined' do
      let(:mail) { described_class.successful_cancellation(shipment) }

      it 'sends the email to the support email' do
        expect(mail.to).to eq([support_email])
      end
    end
  end
end
