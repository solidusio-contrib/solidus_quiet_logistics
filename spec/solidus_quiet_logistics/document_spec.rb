# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusQuietLogistics::Document do
  describe '.from_message' do
    subject(:document) { document_klass.from_message(message) }

    let(:document_klass) do
      Class.new(SolidusQuietLogistics::Document) do
        class << self
          def from_xml(fake_xml)
            new(fake_xml[:valid])
          end

          def s3_bucket
            'test_bucket'
          end
        end

        attr_reader :valid

        def initialize(valid)
          @valid = valid
        end
      end
    end

    let(:message) { instance_double('SolidusQuietLogistics::Message', document_name: 'test_doc') }

    before do
      allow(SolidusQuietLogistics::Aws::Clients.s3).to receive(:get_object)
        .with(key: 'test_doc', bucket: 'test_bucket')
        .and_return(OpenStruct.new(body: OpenStruct.new(read: { valid: true })))
    end

    it 'builds the document from a message' do
      expect(document.valid).to eq(true)
    end
  end
end
