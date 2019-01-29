# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusQuietLogistics::Message do
  subject(:message) do
    described_class.new(
      client_id: 'QUIET',
      business_unit: 'QUIET',
      document_name: 'QUIET_PurchaseOrder_1234_20100927_132505124.xml',
      document_type: 'ShipmentOrderResult',
      id: 'EF1CE966-38A2-428b-BA67-EFF23AF22F57',
      warehouse: 'CORP1',
      message_date: Time.parse('2009-09-01T12:00:00Z'),
    )
  end

  describe '.new' do
    it 'can be called with a hash' do
      expect(described_class.new(document_type: 'Test').document_type).to eq('Test')
    end
  end

  describe '.from_xml' do
    context 'with valid XML' do
      let(:message_body) do
        <<~XML
          <?xml version="1.0" encoding="utf-8"?>
          <EventMessage
            xmlns="http://schemas.SolidusQuietLogistics.com/V2/EventMessage.xsd"
            ClientId="QUIET"
            BusinessUnit="QUIET"
            DocumentName="QUIET_PurchaseOrder_1234_20100927_132505124.xml"
            DocumentType="ShipmentOrderResult"
            MessageId="EF1CE966-38A2-428b-BA67-EFF23AF22F57"
            Warehouse="CORP1"
            MessageDate="2009-09-01T12:00:00Z">
          </EventMessage>
        XML
      end

      it 'creates a message from XML' do
        expect(described_class.from_xml(message_body)).to be_instance_of(described_class)
      end
    end

    context 'with invalid XML' do
      let(:message_body) do
        <<~XML
          <?xml version="1.0" encoding="utf-8"?>
          <InvalidEventMessage
            foo="bar">
          </InvalidEventMessage>
        XML
      end

      it 'raises an InvalidMessageError' do
        expect do
          described_class.from_xml(message_body)
        end.to raise_error(SolidusQuietLogistics::Error::InvalidMessageError)
      end
    end
  end

  describe '#to_xml' do
    it 'generates the right XML' do
      expect(Nokogiri::XML(message.to_xml).css('EventMessage')[0].to_h).to match(
        'ClientId' => 'QUIET',
        'BusinessUnit' => 'QUIET',
        'DocumentName' => 'QUIET_PurchaseOrder_1234_20100927_132505124.xml',
        'DocumentType' => 'ShipmentOrderResult',
        'MessageId' => 'EF1CE966-38A2-428b-BA67-EFF23AF22F57',
        'Warehouse' => 'CORP1',
        'MessageDate' => '2009-09-01T12:00:00Z',
      )
    end
  end
end
