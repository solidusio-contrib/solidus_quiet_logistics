# frozen_string_literal: true

module SolidusQuietLogistics
  module Error
    class InvalidMessageError < SolidusQuietLogistics::Error::ServiceError
      attr_reader :message_body

      def initialize(message_body, *other)
        @message_body = message_body
        super 'Invalid message provided', *other
      end
    end
  end
end
