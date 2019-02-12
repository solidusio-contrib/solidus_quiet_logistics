class AddQlCancellationFieldToSpreeShipment < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_shipments, :ql_cancellation_sent, :datetime
    add_column :spree_shipments, :ql_cancellation_date, :datetime
  end
end
