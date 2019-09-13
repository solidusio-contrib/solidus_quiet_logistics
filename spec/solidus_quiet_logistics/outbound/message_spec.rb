# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusQuietLogistics::Outbound::Message do
  subject(:message) do
    described_class.new(
      document_type: 'ShipmentOrder',
      document_name: 'test.xml',
    )
  end

  describe '#send_to_sqs' do
    before do
      allow(SolidusQuietLogistics::Aws::Clients).to receive(:sqs)
        .and_return(sqs_client)
    end

    let(:sqs_client) do
      Class.new do
        def sent_messages
          @sent_messages ||= []
        end

        def send_message(options)
          sent_messages << options
        end
      end.new
    end

    it 'sets missing attributes' do
      message.send_to_sqs

      message_body = Nokogiri::XML(sqs_client.sent_messages.first[:message_body])
      message_attributes = message_body.css('EventMessage')[0].to_h

      expect(message_attributes).to match(a_hash_including(
        'ClientId' => SolidusQuietLogistics.configuration.client_id,
      ))
    end

    it 'sends the message to SQS' do
      message.send_to_sqs

      expect(sqs_client.sent_messages).to match_array([
        queue_url: SolidusQuietLogistics.configuration.aws_outbox_queue_url,
        message_body: an_instance_of(String),
      ])
    end
  end
end
