# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusQuietLogistics::Outbound::PushRMADocumentJob do
  subject { -> { described_class.perform_now(return_authorization) } }

  let(:return_authorization) { create(:return_authorization) }

  let(:rma_document) do
    instance_spy('SolidusQuietLogistics::Outbound::Document::RMADocument')
  end

  before do
    allow(SolidusQuietLogistics::Outbound::Document::RMADocument).to receive(:new)
      .with(return_authorization)
      .and_return(rma_document)
  end

  it 'processes the rma' do
    subject.call

    expect(rma_document).to have_received(:process)
  end
end
