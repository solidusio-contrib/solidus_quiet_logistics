SolidusQuietLogistics.configure do |config|
  config.enabled = -> (order) { true }
  config.support_email = 'support@example.com'

  # Quiet Logistics configuration ( provided by QL )
  config.client_id = 'CLIENT_ID'
  config.business_unit = 'BUSINESS_UNIT'
  config.warehouse = 'WAREHOUSE'

  # Quiet Logistics AWS credentials ( provided by QL )
  config.aws_access_key_id = 'AWS_ACCESS_KEY_ID'
  config.aws_secret_access_key = 'AWS_SECRET_ACCESS_KEY'
  config.aws_region = 'AWS_REGION'
  config.aws_outbox_bucket = 'AWS_OUTBOX_BUCKET'
  config.aws_outbox_queue_url = 'AWS_OUTBOX_QUEUE_URL'
  config.aws_inbox_bucket = 'AWS_INBOX_BUCKET'
  config.aws_inbox_queue_url = 'AWS_INBOX_QUEUE_URL'

  # Enable or disable the special_service_amount attribute
  # based on the shipment final_price
  # config.order_special_service_amount = -> (shipment) do
  #   'SIGNATURE' if shipment.final_price_with_items > 500
  # end

  # Add the order gift message if your application
  # provides this feature
  # config.order_gift_message = -> (order) do
  #   order.gift_message if order.gift_message?
  # end

  # Return authorization
  # Default rma correct product statuses.
  # An RMA will be considered correct if the product status is GOOD or
  # DAMAGED and incorrect if the product status is INCORRECT.
  # Here you can change the default behaviour
  config.rma_correct_product_statuses = ['GOOD', 'DAMAGED']
end
