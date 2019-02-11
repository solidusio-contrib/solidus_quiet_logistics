# frozen_string_literal: true

module SolidusQuietLogistics
  module Admin
    module OrdersController
      module AddQuietLogisticsHelper
        def self.prepended(base)
          base.helper QuietLogisticsHelper
        end

        Spree::Admin::OrdersController.prepend self
      end
    end
  end
end
