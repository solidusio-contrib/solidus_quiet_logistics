# frozen_string_literal: true

module SolidusQuietLogistics
  class Document
    class << self
      def from_xml(_xml)
        fail NotImplementedError
      end

      def from_message(message)
        from_xml(SolidusQuietLogistics::Aws::Clients.s3.get_object(
          bucket: s3_bucket,
          key: message.document_name,
        ).body.read)
      end

      def s3_bucket
        fail NotImplementedError
      end
    end

    def process
      fail NotImplementedError
    end

    def to_xml
      fail NotImplementedError
    end

    def to_message
      fail NotImplementedError
    end
  end
end
