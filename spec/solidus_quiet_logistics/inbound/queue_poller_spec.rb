# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusQuietLogistics::Inbound::QueuePoller do
  subject { described_class.new }

  let(:sqs_poller) { instance_double('Aws::SQS::QueuePoller') }

  let(:messages) do
    [
      instance_double('Aws::SQS::Message', body: 'message_1'),
      instance_double('Aws::SQS::Message', body: 'message_2'),
    ]
  end

  before do
    allow(Aws::SQS::QueuePoller).to receive(:new)
      .and_return(sqs_poller)

    allow(sqs_poller).to receive(:poll)
      .once
      .and_yield(messages)
  end

  it 'enqueues processing of each message' do
    expect(SolidusQuietLogistics::Inbound::ProcessMessageJob).to receive(:perform_later).twice
    subject.start
  end
end
