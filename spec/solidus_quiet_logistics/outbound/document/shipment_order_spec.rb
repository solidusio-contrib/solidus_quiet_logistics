# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusQuietLogistics::Outbound::Document::ShipmentOrder do
  include_context 'quiet_logistics_outbound_document'

  describe '.document_type' do
    it { expect(described_class.document_type).to eq('ShipmentOrder') }
  end

  describe '#to_xml' do
    subject(:document) { described_class.new(shipment).to_xml }

    let(:ql_client_id) { SolidusQuietLogistics.configuration.client_id }
    let(:ql_business_unit) { SolidusQuietLogistics.configuration.business_unit }

    let(:shipping_method) do
      create(
        :shipping_method,
        code: code,
        carrier: carrier_name,
        service_level: service_level,
      )
    end

    let(:code) { 'Fedex|Ground home' }
    let(:carrier_name) { 'FEDEX' }
    let(:service_level) { 'GROUND' }
    let(:order_priority) { 'STANDARD' }
    let(:gift_message) { nil }

    let(:order) do
      create(
        :order_with_line_items,
        line_items_count: 2,
        shipping_method: shipping_method,
      )
    end

    let(:ship_address) { order.ship_address }
    let(:bill_address) { order.bill_address }
    let(:shipment) { order.shipments.first }
    let(:first_line_item) { shipment.line_items.first }
    let(:second_line_item) { shipment.line_items.second }

    let(:order_date) { order.created_at.strftime('%Y-%m-%dT%H:%M:%SZ') }

    let(:xml) {
      <<~XML
        <?xml version="1.0" encoding="utf-8"?>
        <ShipOrderDocument xmlns="http://schemas.quietlogistics.com/V2/ShipmentOrder.xsd">
          <ClientID>#{ql_client_id}</ClientID>
          <BusinessUnit>#{ql_business_unit}</BusinessUnit>
          <OrderHeader OrderNumber="#{shipment.number}" OrderType="SO" CustomerPO="#{shipment.number}" VIPCustomer="false" StoreDelivery="false" Gift="#{gift_message.present?}" OrderPriority="#{order_priority}" OrderDate="#{order_date}">
            <Comments>#{gift_message}</Comments>
            <ShipMode Carrier="#{shipping_method.carrier}" ServiceLevel="#{shipping_method.service_level}"/>
            <ShipTo Contact="#{ship_address.full_name}" Address1="#{ship_address.address1}" Address2="#{ship_address.address2}" City="#{ship_address.city}" State="#{ship_address.state.name}" PostalCode="#{ship_address.zipcode}" Country="#{ship_address.country.iso}" Phone="#{ship_address.phone}" Email="#{order.email}"/>
            <BillTo Contact="#{bill_address.full_name}" Address1="#{bill_address.address1}" Address2="#{bill_address.address2}" City="#{bill_address.city}" State="#{bill_address.state.name}" PostalCode="#{bill_address.zipcode}" Country="#{bill_address.country.iso}" Phone="#{bill_address.phone}" Email="#{order.email}"/>
            <ValueAddedService Service="string" ServiceType="string"/>
          </OrderHeader>
          <OrderDetails Line="1" ItemNumber="#{first_line_item.sku}" QuantityOrdered="#{first_line_item.quantity}" QuantityToShip="#{first_line_item.quantity}" Price="#{first_line_item.price}" UOM="EA"/>
          <OrderDetails Line="2" ItemNumber="#{second_line_item.sku}" QuantityOrdered="#{second_line_item.quantity}" QuantityToShip="#{second_line_item.quantity}" Price="#{second_line_item.price}" UOM="EA"/>
        </ShipOrderDocument>
      XML
    }

    context 'with gift message' do
      let(:gift_message) { 'Happy birthday' }

      before do
        allow(SolidusQuietLogistics.configuration)
          .to receive(:order_gift_message)
          .and_return(proc { |order| gift_message })
      end

      it 'checks XML string is correct' do
        expect(document).to eq(xml)
      end
    end

    context 'without gift message' do
      it 'checks XML string is correct' do
        expect(document).to eq(xml.gsub(/\s{4}<Comments><\/Comments>\n/, ""))
      end
    end

    context 'when the shipment\'s final price is greater than the special service amount' do
      before do
        allow(SolidusQuietLogistics.configuration)
          .to receive(:order_special_service_amount)
          .and_return(proc { |shipment| 'SIGNATURE' })
      end

      it 'XML document contains the special service node' do
        expect(document).to a_string_including('<ShipSpecialService>SIGNATURE</ShipSpecialService>')
      end
    end
  end

  describe '#process' do
    subject(:document) { described_class.new(shipment) }

    let(:shipment) { create(:shipment, shipping_method: shipping_method, pushed: pushed) }
    let(:shipping_method) do
      create(:shipping_method, code: code, carrier: carrier_name, service_level: service_level)
    end

    let(:code) { 'Fedex|2 Day' }
    let(:carrier_name) { 'FEDEX' }
    let(:service_level) { '2DAY' }
    let(:pushed) { false }

    it 'marks the shipments as shipped' do
      expect do
        document.process
        shipment.reload
      end.to change(shipment, :pushed).to(true)
    end

    context 'if the shipment was already pushed' do
      let(:pushed) { true }

      it 'fails with invalid shipping method error' do
        expect { document.process }.to raise_error(SolidusQuietLogistics::Outbound::Error::AlreadyPushedError)
      end
    end
  end
end
