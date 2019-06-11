# frozen_string_literal: true

require 'spec_helper'

describe 'Create Return Authorization', type: :feature, js: true do
  include Warden::Test::Helpers

  let(:user) { create(:admin_user) }

  let(:order) { create(:order_ready_to_ship) }
  let(:shipment) { order.shipments.first }
  let(:quiet_logistics_enabled) { true }

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

    context 'when quiet_logistics is enabled' do
      it 'is not visible' do
        expect(page).not_to have_selector('[data-hook="toolbar"]')
      end
    end

    context 'when quiet_logistics is not enabled' do
      let(:quiet_logistics_enabled) { false }

      it 'is visible' do
        expect(page).to have_selector('[data-hook="toolbar"]')
      end
    end
  end

  describe 'RMA actions' do
    let!(:return_authorization) { create(:return_authorization, order: order) }

    context 'with the button' do
      before { visit spree.admin_order_return_authorizations_path(order) }

      context 'when quiet_logistics is enabled' do
        it 'are not visible' do
          expect(page).not_to have_selector('[data-hook="rma_row"] .actions')
        end
      end

      context 'when quiet_logistics is not enabled' do
        let(:quiet_logistics_enabled) { false }

        it 'are visible' do
          expect(page).to have_selector('[data-hook="rma_row"] .actions')
        end
      end
    end

    context 'with the URL' do
      before { visit spree.edit_admin_order_return_authorization_path(order, return_authorization) }

      context 'when quiet_logistics is enabled' do
        it 'redirects to admin_order_return_authorizations_path and shows error message' do
          expect(page).not_to have_selector('.return-items-table')
          expect(page).to have_content(Spree.t('cannot_perform_operation'))
        end
      end

      context 'when quiet_logistics is not enabled' do
        let(:quiet_logistics_enabled) { false }

        it 'shows edit form' do
          expect(page).to have_selector('.return-items-table')
        end
      end
    end
  end

  describe 'Create RMA from the shipment' do
    before { visit spree.edit_admin_order_path(order) }

    context 'when quiet_logistics is enabled' do
      it 'is visible and creates the RMA with the shipment inventory units' do
        expect(page).to have_selector('.shipment-rma', count: order.shipments.count)

        find_all('.shipment-rma').first.click

        expect(page).to have_selector('.return-items-table tbody tr',
          count: shipment.inventory_units.count)
      end
    end

    context 'when quiet_logistics is not enabled' do
      let(:quiet_logistics_enabled) { false }

      it 'is not visible' do
        expect(page).not_to have_selector('.shipment-rma')
      end
    end
  end
end