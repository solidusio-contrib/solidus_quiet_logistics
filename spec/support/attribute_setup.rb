# frozen_string_literal: true

SolidusQuietLogistics.configure do |config|
  config.client_id = 'client_id'
  config.business_unit = 'business_unit'

  config.aws_region = 'aws_region'
  config.aws_outbox_queue_url = 'aws_outbox_queue_url'
  config.aws_outbox_bucket = 'aws_outbox_bucket'

  config.order_special_service_amount = 500
end
