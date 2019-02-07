# frozen_string_literal: true

module SolidusQuietLogistics
  module Inbound
    class ProcessMessageJob < ActiveJob::Base
      queue_as :default

      def perform(message_body)
        SolidusQuietLogistics::Inbound::MessageProcessor.process(message_body)
      rescue SolidusQuietLogistics::Inbound::Error::UnhandledMessageError => e
        Rails.logger.info "Discarding unhandled message of type '#{e.message.document_type}'"
      rescue SolidusQuietLogistics::Error::InvalidMessageError => e
        Rails.logger.error "Discarding invalid message: #{e.message_body}"
      end
    end
  end
end
