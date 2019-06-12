# frozen_string_literal: true

module SolidusQuietLogistics
  module Outbound
    class PushRMADocumentJob < ActiveJob::Base
      queue_as :default

      def perform(return_authorization)
        return unless SolidusQuietLogistics.configuration.enabled&.call(return_authorization.order)

        SolidusQuietLogistics::Outbound::Document::RMADocument.new(return_authorization).process
      end
    end
  end
end
