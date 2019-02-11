# frozen_string_literal: true

module QuietLogisticsHelpers
  def read_ql_message(document_type)
    File.read(Rails.root.join('..', 'support', 'files', 'solidus_quiet_logistics', 'messages', "#{document_type}.xml"))
  end

  def read_ql_document(document_type)
    File.read(Rails.root.join('..', 'support', 'files', 'solidus_quiet_logistics', 'documents', "#{document_type}.xml"))
  end
end

RSpec.configure do |config|
  config.include QuietLogisticsHelpers
end

RSpec.shared_context 'quiet_logistics_inbound_integration' do
  include ActiveJob::TestHelper

  subject do
    proc do
      perform_enqueued_jobs do
        SolidusQuietLogistics::Inbound::QueuePoller.new(sqs_poller: dummy_poller).start
      end
    end
  end

  let(:dummy_poller) { instance_double('Aws::SQS::QueuePoller') }

  before do
    allow(dummy_poller).to receive(:poll).and_yield([
      instance_double('Aws::SQS::Message', body: read_ql_message(document_type)),
    ])

    allow(SolidusQuietLogistics::Aws::Clients.s3).to receive(:get_object)
      .with(a_hash_including(bucket: SolidusQuietLogistics.configuration.aws_input_bucket))
      .and_return(OpenStruct.new(
        body: OpenStruct.new(read: read_ql_document(document_type)),
      ))
  end
end

RSpec.shared_context 'quiet_logistics_outbound_document' do
  before do
    allow(SolidusQuietLogistics::Aws::Clients).to receive(:s3).and_return(s3_client)
    allow(SolidusQuietLogistics::Outbound::Message).to receive(:new).and_return(message)
  end

  let(:s3_client) { instance_spy('Aws::S3::Client') }
  let(:message) { instance_spy('SolidusQuietLogistics::Outbound::Message') }
end
