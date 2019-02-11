# frozen_string_literal: true

module QuietLogisticsHelper
  def shipment_order(shipment)
    element(
      class: 'ql-shipment-order',
      complete: shipment.pushed?,
      label: t('quiet_logistics.shipment_order.label'),
    ) do
      if shipment.pushed?
        t('quiet_logistics.shipment_order.pushed')
      else
        t('quiet_logistics.shipment_order.not_pushed')
      end
    end
  end

  private

  def element(**args, &_block)
    label = content_tag :dt, class: args[:class] do
      args[:label]
    end

    content = content_tag :dd, class: args[:class] do
      content_tag :span, class: "state #{'complete' if args[:complete]}" do
        yield
      end
    end

    label + content
  end
end
