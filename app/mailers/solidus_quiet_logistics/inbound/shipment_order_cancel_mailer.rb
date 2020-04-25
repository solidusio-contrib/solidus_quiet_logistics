# frozen_string_literal: true

module SolidusQuietLogistics
  module Inbound
    class ShipmentOrderCancelMailer < BaseMailer
      def failed_cancellation(shipment, recipient: support_email)
        return if support_email.blank?

        @order = shipment.order
        @shipment = shipment

        mail(
          to: recipient,
          from: from_address(::Spree::Store.default),
          subject: t('quiet_logistics.mailers.shipment_cancellation_failed.title'),
        )
      end

      def successful_cancellation(shipment, recipient: support_email)
        return if support_email.blank?

        @order = shipment.order
        @shipment = shipment

        mail(
          to: recipient,
          from: from_address(::Spree::Store.default),
          subject: t('quiet_logistics.mailers.shipment_successfully_cancelled.title'),
        )
      end
    end
  end
end
