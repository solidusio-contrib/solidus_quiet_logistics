# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusQuietLogistics::Inbound::ProcessMessageJob do
  subject { -> { described_class.perform_now(message_body) } }

  let(:message_body) { 'test' }

  it 'processes the message body' do
    expect(SolidusQuietLogistics::Inbound::MessageProcessor).to receive(:process)
      .with(message_body)
      .once

    subject.call
  end
end
