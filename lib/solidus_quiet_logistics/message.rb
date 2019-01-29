# frozen_string_literal: true

module SolidusQuietLogistics
  class Message
    class << self
      def from_xml(message_body)
        message_element = Nokogiri::XML(message_body).css('EventMessage')[0]
        fail SolidusQuietLogistics::Error::InvalidMessageError, message_body unless message_element

        attributes = message_element.to_h

        new(
          client_id: attributes['ClientId'],
          business_unit: attributes['BusinessUnit'],
          document_name: attributes['DocumentName'],
          document_type: attributes['DocumentType'],
          id: attributes['MessageId'],
          warehouse: attributes['Warehouse'],
          message_date: Time.parse(attributes['MessageDate']),
        )
      end
    end

    ATTRIBUTES = %i(
      client_id
      business_unit
      document_name
      document_type
      id
      warehouse
      message_date
    ).freeze

    attr_reader(*ATTRIBUTES)

    def initialize(attributes = {})
      attributes.each_pair do |key, value|
        unless ATTRIBUTES.include?(key.to_sym)
          fail(
            ArgumentError,
            "#{key} is an invalid attribute (valid attributes: #{ATTRIBUTES.join(', ')})",
          )
        end

        instance_variable_set("@#{key}", value)
      end
    end

    def to_xml
      Nokogiri::XML::Builder.new(encoding: 'utf-8') do |xml|
        xml.EventMessage(
          xmlns: 'http://schemas.quietlogistics.com/V2/EventMessage.xsd',
          ClientId: client_id,
          BusinessUnit: business_unit,
          DocumentName: document_name,
          DocumentType: document_type,
          MessageId: id,
          Warehouse: warehouse,
          MessageDate: message_date.iso8601,
        )
      end.to_xml
    end
  end
end
