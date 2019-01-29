# frozen_string_literal: true

module SolidusQuietLogistics
  module Outbound
    module Error
      ServiceError = Class.new(SolidusQuietLogistics::Error::ServiceError)
    end
  end
end
