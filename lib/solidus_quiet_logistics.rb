require 'solidus_core'
require 'deface'

require 'solidus_quiet_logistics/version'

require 'solidus_quiet_logistics/document'
require 'solidus_quiet_logistics/message'

require 'solidus_quiet_logistics/aws/clients'
require 'solidus_quiet_logistics/aws/credentials'

require 'solidus_quiet_logistics/error/service_error'
require 'solidus_quiet_logistics/error/invalid_message_error'

require 'solidus_quiet_logistics/inbound/error/service_error'
require 'solidus_quiet_logistics/inbound/error/unhandled_message_error'

require 'solidus_quiet_logistics/inbound/document'
require 'solidus_quiet_logistics/inbound/document/inventory_summary_ready'
require 'solidus_quiet_logistics/inbound/document/rma_result_document'
require 'solidus_quiet_logistics/inbound/document/shipment_order_cancel_ready'
require 'solidus_quiet_logistics/inbound/document/shipment_order_result'

require 'solidus_quiet_logistics/inbound/message'
require 'solidus_quiet_logistics/inbound/message_processor'
require 'solidus_quiet_logistics/inbound/queue_poller'

require 'solidus_quiet_logistics/outbound/error/service_error'
require 'solidus_quiet_logistics/outbound/error/already_pushed_error'

require 'solidus_quiet_logistics/outbound/document'
require 'solidus_quiet_logistics/outbound/document/inventory_summary_request'
require 'solidus_quiet_logistics/outbound/document/rma_document'
require 'solidus_quiet_logistics/outbound/document/shipment_order'
require 'solidus_quiet_logistics/outbound/document/shipment_order_cancel'

require 'solidus_quiet_logistics/outbound/message'

require 'solidus_quiet_logistics/engine'

class Configuration
  # QL
  attr_accessor :enabled, :client_id, :business_unit, :warehouse, :support_email

  # AWS
  attr_accessor :aws_region, :aws_access_key_id, :aws_secret_access_key,
    :aws_inbox_queue_url, :aws_inbox_bucket, :aws_outbox_bucket, :aws_outbox_queue_url

  # Custom fields
  attr_accessor :order_gift_message, :order_special_service_amount

  # Return authorization
  attr_accessor :rma_correct_product_statuses
end

module SolidusQuietLogistics
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration
  end
end
