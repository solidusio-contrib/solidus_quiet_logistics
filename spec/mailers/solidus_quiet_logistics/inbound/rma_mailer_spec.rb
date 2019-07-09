# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusQuietLogistics::Inbound::RMAMailer, type: :mailer do
  let(:support_email) { 'support@example.com' }

  let(:return_authorization) { create(:return_authorization) }
  let(:return_items) do
    [
      create(:return_item, return_authorization: return_authorization),
      create(:return_item, return_authorization: return_authorization),
    ]
  end

  before do
    allow(SolidusQuietLogistics.configuration).to receive(:support_email)
      .and_return(support_email)
  end

  describe '.failed_refund_to_customer' do
    let(:mail) { described_class.failed_refund_to_customer(return_authorization, return_items) }

    it 'sends the email to the user' do
      expect(mail.to).to eq([return_authorization.order.user.email])
    end
  end

  describe '.failed_refund_to_support' do
    let(:mail) { described_class.failed_refund_to_support(return_authorization, return_items) }

    it 'sends the email to the support email' do
      expect(mail.to).to eq([support_email])
    end
  end
end
