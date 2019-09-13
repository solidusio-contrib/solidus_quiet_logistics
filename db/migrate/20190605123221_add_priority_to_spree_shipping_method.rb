# frozen_string_literal: true

class AddPriorityToSpreeShippingMethod < SolidusSupport::Migration[4.2]
  def change
    add_column :spree_shipping_methods, :priority, :string, default: 'STANDARD'
  end
end
