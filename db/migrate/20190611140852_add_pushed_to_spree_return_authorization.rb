class AddPushedToSpreeReturnAuthorization < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_return_authorizations, :pushed, :boolean, default: false

    reversible do |dir|
      dir.up do
        Spree::ReturnAuthorization.all.each do |return_authorization|
          if (SolidusQuietLogistics.configuration.enabled&.call(return_authorization.order))
            return_authorization.update!(pushed: true)
          end
        end
      end
    end
  end
end
