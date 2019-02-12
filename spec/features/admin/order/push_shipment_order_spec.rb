# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Push shipment order', type: :feature, js: true do
  include Warden::Test::Helpers
  include Spree::BaseHelper

  let!(:store) { create(:store) }
  let(:admin_user) { create(:admin_user) }

  before do
    login_as admin_user
  end

  context 'when the order has QL logistics provider' do
    let(:order) { create(:order_ready_to_ship) }

    let(:shipment) { order.shipments.first }

    before do
      shipment.update!(pushed: pushed)

      visit spree.edit_admin_order_path(order)
    end

    context 'when shipment is not pushed to QL' do
      let(:pushed) { false }

      it 'shows push shipment order button' do
        expect(page).to have_selector('.push-shipment')
      end
    end

    context 'when shipment is pushed to QL' do
      let(:pushed) { true }

      it 'does not show push shipment order button' do
        expect(page).not_to have_selector('.push-shipment')
      end
    end
  end
end
