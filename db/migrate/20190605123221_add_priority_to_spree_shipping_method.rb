class AddPriorityToSpreeShippingMethod < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_shipping_methods, :priority, :string, default: 'STANDARD'
  end
end
