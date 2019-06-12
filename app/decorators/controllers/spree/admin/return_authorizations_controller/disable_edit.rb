# frozen_string_literal: true

module SolidusQuietLogistics
  module Admin
    module ReturnAuthorizations
      module DisableEdit
        def edit
          if SolidusQuietLogistics.configuration.enabled&.call(@return_authorization.order)
            flash[:error] = I18n.t('spree.cannot_perform_operation')
            redirect_to admin_order_return_authorizations_path(@return_authorization.order)
          else
            super
          end
        end

        Spree::Admin::ReturnAuthorizationsController.prepend self
      end
    end
  end
end
