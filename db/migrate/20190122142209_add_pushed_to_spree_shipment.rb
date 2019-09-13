class AddPushedToSpreeShipment < SolidusSupport::Migration[4.2]
  def change
    add_column :spree_shipments, :pushed, :boolean, default: false

    reversible do |dir|
      dir.up do
        Spree::Shipment.shipped.update_all(pushed: true)
      end
    end
  end
end
