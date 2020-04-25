# frozen_string_literal: true

module SolidusQuietLogistics
  module Spree
    module Admin
      module ReturnAuthorizations
        module OverrideLoadReturnItems
          def self.prepended(base)
            base.prepend_before_action :load_shipment, only: %i[new edit]
            base.attr_reader :shipment, :return_authorization
          end

          def load_return_items
            if SolidusQuietLogistics.configuration.enabled&.call(return_authorization.order)
              load_shipment_return_items
            else
              load_order_return_items
            end
          end

          private

          def load_shipment
            @shipment = ::Spree::Shipment.find_by(number: params[:shipment_id])
          end

          def load_shipment_return_items
            all_inventory_units = shipment ? shipment.inventory_units : return_authorization.order.inventory_units
            associated_inventory_units = return_authorization.return_items.map(&:inventory_unit)
            unassociated_inventory_units = all_inventory_units - associated_inventory_units

            new_return_items = unassociated_inventory_units.map do |new_unit|
              ::Spree::ReturnItem.new(inventory_unit: new_unit).tap(&:set_default_amount)
            end

            @form_return_items = (return_authorization.return_items + new_return_items).sort_by(&:inventory_unit_id)
          end

          def load_order_return_items
            all_inventory_units = return_authorization.order.inventory_units
            associated_inventory_units = return_authorization.return_items.map(&:inventory_unit)
            unassociated_inventory_units = all_inventory_units - associated_inventory_units

            new_return_items = unassociated_inventory_units.map do |new_unit|
              ::Spree::ReturnItem.new(inventory_unit: new_unit).tap(&:set_default_amount)
            end
            @form_return_items = (return_authorization.return_items + new_return_items).sort_by(&:inventory_unit_id)
          end

          ::Spree::Admin::ReturnAuthorizationsController.prepend self
        end
      end
    end
  end
end
