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

  def shipment_order_cancel(shipment)
    if shipment.ql_cancellation_date.present?
      element(
        class: 'ql-shipment-order-cancel',
        complete: true,
        label: t('quiet_logistics.admin.shipment_order_cancel.cancellation_label'),
      ) do
        t('quiet_logistics.admin.shipment_order_cancel.cancellation_date', cancellation_date: pretty_time(shipment.ql_cancellation_date))
      end
    else
      element(
        class: 'ql-shipment-order-cancel',
        complete: shipment.ql_cancellation_sent.present?,
        label: t('quiet_logistics.admin.shipment_order_cancel.sent_label'),
      ) do
        if shipment.ql_cancellation_sent.present?
          t('quiet_logistics.admin.shipment_order_cancel.sent', cancellation_date: pretty_time(shipment.ql_cancellation_sent))
        else
          t('quiet_logistics.admin.shipment_order_cancel.not_sent')
        end
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
