# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Shipping method form', type: :feature, js: true do
  include Warden::Test::Helpers
  include Spree::BaseHelper

  let!(:store) { create(:store) }
  let(:admin_user) { create(:admin_user) }

  before do
    login_as admin_user
  end

  it 'shows priority field' do
    visit spree.new_admin_shipping_method_path

    expect(page).to have_selector('[data-hook="admin_shipping_method_form_priority_field"]')
  end
end
