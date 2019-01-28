# frozen_string_literal: true

module SolidusQuietLogistics
  module Outbound
    module Error
      class AlreadyPushedError < SolidusQuietLogistics::Outbound::Error::ServiceError
        def initialize(object, *other)
          super "This #{object} is already pushed", *other
        end
      end
    end
  end
end
