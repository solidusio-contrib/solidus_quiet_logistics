# frozen_string_literal: true

module SolidusQuietLogistics
  module Outbound
    class Document < SolidusQuietLogistics::Document
      class << self
        def s3_bucket
          SolidusQuietLogistics.configuration.aws_outbox_bucket
        end

        def document_type
          fail NotImplementedError
        end
      end

      def process
        validate_context
        upload_to_s3
        send_message_to_sqs
      end

      private

      def validate_context; end

      def document_name
        fail NotImplementedError
      end

      def to_message
        SolidusQuietLogistics::Outbound::Message.new(
          document_name: document_name,
          document_type: self.class.document_type,
        )
      end

      def send_message_to_sqs
        to_message.send_to_sqs
      end

      def upload_to_s3
        SolidusQuietLogistics::Aws::Clients.s3.put_object(
          key: document_name,
          bucket: self.class.s3_bucket,
          body: to_xml,
        )
      end
    end
  end
end
