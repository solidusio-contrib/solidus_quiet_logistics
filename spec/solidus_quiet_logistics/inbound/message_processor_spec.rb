# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusQuietLogistics::Inbound::MessageProcessor do
  subject { described_class }

  let(:message_body) { 'test' }

  before do
    allow(SolidusQuietLogistics::Message).to receive(:from_xml)
      .and_return(message)
  end

  context 'with a handled message' do
    let(:message) do
      instance_double(
        'SolidusQuietLogistics::Message',
        document_type: 'ShipmentOrderResult',
        document_name: 'document_name',
      )
    end

    let(:document) do
      instance_double('SolidusQuietLogistics::Inbound::Document::ShipmentOrderResult')
    end

    before do
      allow(SolidusQuietLogistics::Inbound::Document::ShipmentOrderResult).to receive(:from_message)
        .with(message)
        .once
        .and_return(document)

      allow(document).to receive(:process)
    end

    it 'processes with the right handler' do
      expect(document).to receive(:process)

      subject.process(message_body)
    end
  end

  context 'with an unhandled message' do
    let(:message) do
      instance_double(
        'SolidusQuietLogistics::Message',
        document_type: 'UnhandledMessageType',
        document_name: 'document_name',
      )
    end

    it 'raises an UnhandledMessageError' do
      expect do
        subject.process(message_body)
      end.to raise_error(SolidusQuietLogistics::Inbound::Error::UnhandledMessageError)
    end
  end
end
