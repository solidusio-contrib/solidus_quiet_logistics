# frozen_string_literal: true

module SolidusQuietLogistics
  module Spree
    module Order
      module OverrideAfterCancel
        def after_cancel
          payments.completed.each(&:cancel!)
          payments.store_credits.pending.each(&:void_transaction!)
          recalculate
        end

        ::Spree::Order.prepend self
      end
    end
  end
end
