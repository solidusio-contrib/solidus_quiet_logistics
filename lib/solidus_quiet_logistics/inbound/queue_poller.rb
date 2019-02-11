# frozen_string_literal: true

module SolidusQuietLogistics
  module Inbound
    class QueuePoller
      BATCH_SIZE = 10

      def initialize(sqs_poller: nil)
        @sqs_poller = sqs_poller || ::Aws::SQS::QueuePoller.new(
          SolidusQuietLogistics.configuration.aws_inbox_queue_url,
          client: SolidusQuietLogistics::Aws::Clients.sqs,
        )
      end

      def start
        sqs_poller.poll(max_number_of_messages: BATCH_SIZE) do |messages|
          messages.each do |message|
            yield message if block_given?
            process_message(message)
          end
        end
      end

      private

      attr_reader :sqs_poller

      def process_message(message)
        SolidusQuietLogistics::Inbound::ProcessMessageJob.perform_later(message.body)
      end
    end
  end
end
