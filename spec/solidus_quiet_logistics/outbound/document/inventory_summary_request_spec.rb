# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusQuietLogistics::Outbound::Document::InventorySummaryRequest do
  include_context 'quiet_logistics_outbound_document'

  subject(:document) { described_class.new }

  describe '#process' do
    it 'does not raise any errors' do
      expect { document.process }.not_to raise_error
    end
  end
end
