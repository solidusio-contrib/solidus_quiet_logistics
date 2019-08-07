# frozen_string_literal: true

module SolidusQuietLogistics
  module Inbound
    class RmaMailer < BaseMailer
      def failed_refund_to_customer(return_authorization, return_items)
        @return_authorization = return_authorization
        @return_items = return_items

        mail(
          to: return_authorization.order.user.email,
          from: from_address(return_authorization.order.store),
          subject: t(
            'quiet_logistics.mailers.failed_refund_to_customer.subject',
            order_number: return_authorization.order.number,
          ),
        )
      end

      def failed_refund_to_support(return_authorization, return_items)
        @return_authorization = return_authorization
        @return_items = return_items

        mail(
          to: support_email,
          from: from_address(return_authorization.order.store),
          subject: t(
            'quiet_logistics.mailers.failed_refund_to_support.subject',
            order_number: return_authorization.order.number,
            return_authorization_number: return_authorization.number,
          ),
        )
      end
    end
  end
end
