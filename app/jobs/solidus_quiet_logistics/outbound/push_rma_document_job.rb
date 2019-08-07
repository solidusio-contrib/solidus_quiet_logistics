# frozen_string_literal: true

module SolidusQuietLogistics
  module Outbound
    class PushRmaDocumentJob < ActiveJob::Base
      queue_as :default

      def perform(return_authorization)
        return unless SolidusQuietLogistics.configuration.enabled&.call(return_authorization.order)

        SolidusQuietLogistics::Outbound::Document::RmaDocument.new(return_authorization).process
      end
    end
  end
end
