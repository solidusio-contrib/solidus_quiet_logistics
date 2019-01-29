# frozen_string_literal: true

module SolidusQuietLogistics
  module Outbound
    class Message < SolidusQuietLogistics::Message
      attr_writer(*ATTRIBUTES)

      def send_to_sqs
        set_defaults

        SolidusQuietLogistics::Aws::Clients.sqs.send_message(
          queue_url: SolidusQuietLogistics.configuration.aws_outbox_queue_url,
          message_body: to_xml,
        )
      end

      private

      def set_defaults
        {
          client_id: SolidusQuietLogistics.configuration.client_id,
          business_unit: SolidusQuietLogistics.configuration.business_unit,
          id: SecureRandom.uuid,
          warehouse: SolidusQuietLogistics.configuration.warehouse,
          message_date: Time.zone.now,
        }.each_pair do |name, value|
          send("#{name}=", value) if send(name).blank?
        end
      end
    end
  end
end
