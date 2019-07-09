# frozen_string_literal: true

module SolidusQuietLogistics
  module RefundReason
    module FindOrCreateReturnProcessingReason
      def self.prepended(base)
        base.singleton_class.prepend ClassMethods
      end

      module ClassMethods
        def return_processing_reason
          find_or_create_by!(name: 'Return processing', mutable: false)
        end
      end

      Spree::RefundReason.prepend self
    end
  end
end
