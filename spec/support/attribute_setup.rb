# frozen_string_literal: true

SolidusQuietLogistics.configure do |config|
  config.enabled = -> (order) { true }

  config.client_id = 'client_id'
  config.business_unit = 'business_unit'

  config.aws_region = 'aws_region'
  config.aws_outbox_queue_url = 'aws_outbox_queue_url'
  config.aws_outbox_bucket = 'aws_outbox_bucket'

  config.rma_correct_product_statuses = ['GOOD', 'DAMAGED']
end
