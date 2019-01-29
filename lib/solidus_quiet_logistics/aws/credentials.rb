# frozen_string_literal: true

module SolidusQuietLogistics
  module Aws
    class Credentials < ::Aws::Credentials
      def initialize
        super(
          SolidusQuietLogistics.configuration.aws_access_key_id,
          SolidusQuietLogistics.configuration.aws_secret_access_key,
        )
      end
    end
  end
end
