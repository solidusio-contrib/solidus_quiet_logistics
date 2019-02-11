# frozen_string_literal: true

module SolidusQuietLogistics
  module Inbound
    module Error
      class UnhandledMessageError < SolidusQuietLogistics::Inbound::Error::ServiceError
        attr_reader :message

        def initialize(message, *other)
          @message = message
          super "Cannot handle message of type #{message.document_type}", *other
        end
      end
    end
  end
end
