# frozen_string_literal: true

module Spree
  module Admin
    class ShipmentsController < Spree::Admin::BaseController
      before_action :load_shipment, only: %i[destroy push_shipment_order]

      respond_to :html, :js

      attr_reader :shipment

      def destroy
        return super unless SolidusQuietLogistics.configuration.enabled&.call(shipment.order) ||
                            shipment.ql_cancellation_sent.blank? ||
                            shipment.ql_cancellation_date.blank?

        SolidusQuietLogistics::Outbound::PushShipmentOrderCancelDocumentJob
          .perform_later(shipment)
      end

      def push_shipment_order
        if SolidusQuietLogistics.configuration.enabled&.call(shipment.order) && !shipment.pushed?
          SolidusQuietLogistics::Outbound::PushShipmentOrderDocumentJob
            .perform_later(shipment)
        end
      end

      private

      def load_shipment
        @shipment = Spree::Shipment.find_by!(number: params[:id])
        authorize! action, shipment
      end
    end
  end
end
