# frozen_string_literal: true

module SolidusQuietLogistics
  module Aws
    module Clients
      class << self
        def sqs
          @sqs ||= ::Aws::SQS::Client.new(
            region: SolidusQuietLogistics.configuration.aws_region,
            credentials: SolidusQuietLogistics::Aws::Credentials.new,
          )
        end

        def s3
          @s3 ||= ::Aws::S3::Client.new(
            region: SolidusQuietLogistics.configuration.aws_region,
            credentials: SolidusQuietLogistics::Aws::Credentials.new,
          )
        end
      end
    end
  end
end
