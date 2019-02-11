# frozen_string_literal: true

module SolidusQuietLogistics
  module Inbound
    class Document < SolidusQuietLogistics::Document
      class << self
        private

        def s3_bucket
          SolidusQuietLogistics.configuration.aws_inbox_bucket
        end
      end
    end
  end
end
