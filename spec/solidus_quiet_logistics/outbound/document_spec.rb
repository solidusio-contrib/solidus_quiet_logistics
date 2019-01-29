# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusQuietLogistics::Outbound::Document do
  subject { document_klass.new }

  let(:document_klass) do
    Class.new(described_class) do
      class << self
        def document_type; 'test_doc_type'; end
      end

      def to_xml; 'test_xml'; end

      def document_name; 'test_doc_name'; end

      def validate_context; end
    end
  end

  describe '#process' do
    let(:s3_client) { instance_spy('Aws::S3::Client') }
    let(:message) { instance_spy('SolidusQuietLogistics::Outbound::Message') }

    before do
      allow(SolidusQuietLogistics::Aws::Clients).to receive(:s3)
        .and_return(s3_client)

      allow(SolidusQuietLogistics::Outbound::Message).to receive(:new)
        .with(document_name: 'test_doc_name', document_type: 'test_doc_type')
        .and_return(message)

      subject.process
    end

    it 'uploads the document to S3' do
      expect(s3_client).to have_received(:put_object)
        .with(
          key: 'test_doc_name',
          bucket: SolidusQuietLogistics.configuration.aws_outbox_bucket,
          body: 'test_xml',
        )
        .once
    end

    it 'notifies the document on SQS' do
      expect(message).to have_received(:send_to_sqs)
        .once
    end
  end
end
