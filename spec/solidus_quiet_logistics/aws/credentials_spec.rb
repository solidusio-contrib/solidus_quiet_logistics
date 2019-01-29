# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusQuietLogistics::Aws::Credentials do
  subject { described_class.new }

  it 'can be instantiated' do
    expect { subject }.not_to raise_error
  end
end
