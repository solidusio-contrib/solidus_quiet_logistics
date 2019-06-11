# frozen_string_literal: true

require 'spec_helper'

describe 'Create Return Authorization', type: :feature, js: true do
  include Warden::Test::Helpers

  let(:user) { create(:admin_user) }

  let(:order) { create(:order_ready_to_ship) }
  let(:shipment) { order.shipments.first }

  before do
    login_as user

    create(:shipment, order: order, stock_location: shipment.stock_location)
    order.reload.shipments.each(&:ship)

    allow(SolidusQuietLogistics.configuration)
      .to receive(:enabled)
      .and_return(proc { |order| quiet_logistics_enabled })
  end

  describe 'The create RMA button on the whole order' do
    before { visit spree.admin_order_return_authorizations_path(order) }

    context 'when the order has QL logistics provider' do
      let(:quiet_logistics_enabled) { true }

      it 'is not visible' do
        expect(page).not_to have_selector('[data-hook="toolbar"]')
      end
    end

    context 'when the order has not QL logistics provider' do
      let(:quiet_logistics_enabled) { false }

      it 'is visible' do
        expect(page).to have_selector('[data-hook="toolbar"]')
      end
    end
  end
end
