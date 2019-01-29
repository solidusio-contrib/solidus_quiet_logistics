require 'solidus_core'
require 'solidus_quiet_logistics/engine'
require 'deface'

class Configuration
  # QL
  attr_accessor :enabled, :client_id, :business_unit, :warehouse

  # AWS
  attr_accessor :aws_region, :aws_access_key_id, :aws_secret_access_key,
    :aws_inbox_queue_url, :aws_inbox_bucket, :aws_outbox_bucket, :aws_outbox_queue_url

  # Custom fields
  attr_accessor :order_gift_message
  attr_accessor :shipping_attributes
end

module SolidusQuietLogistics
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration
  end
end
