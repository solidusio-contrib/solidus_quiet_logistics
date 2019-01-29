# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusQuietLogistics::Aws::Clients do
  subject { described_class }

  describe '.sqs' do
    it 'returns a valid AWS SQS client' do
      expect(described_class.sqs).to be_instance_of(::Aws::SQS::Client)
    end
  end

  describe '.s3' do
    it 'returns a valid AWS S3 client' do
      expect(described_class.s3).to be_instance_of(::Aws::S3::Client)
    end
  end
end
