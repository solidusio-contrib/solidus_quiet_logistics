class AddQlRmaSentTimestampToSpreeInventoryUnit < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_inventory_units, :ql_rma_sent, :datetime
  end
end
