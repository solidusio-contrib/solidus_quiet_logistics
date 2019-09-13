class AddQlRMASentTimestampToSpreeInventoryUnit < SolidusSupport::Migration[4.2]
  def change
    add_column :spree_inventory_units, :ql_rma_sent, :datetime
  end
end

