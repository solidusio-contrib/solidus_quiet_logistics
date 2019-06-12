# frozen_string_literal: true

module SolidusQuietLogistics
  module Admin
    module ReturnAuthorizations
      module PushRMADocumentAfterCreation
        def create
          super

          SolidusQuietLogistics::Outbound::PushRMADocumentJob.perform_later(@return_authorization) if can_push_rma_document?
        end

        private

        def can_push_rma_document?
          SolidusQuietLogistics.configuration.enabled&.call(return_authorization.order) &&
            return_authorization.persisted?
        end

        Spree::Admin::ReturnAuthorizationsController.prepend self
      end
    end
  end
end
