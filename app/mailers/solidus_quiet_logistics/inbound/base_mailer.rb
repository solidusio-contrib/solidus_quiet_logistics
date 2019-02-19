# frozen_string_literal: true

module SolidusQuietLogistics
  module Inbound
    class BaseMailer < Spree::BaseMailer
      helper ApplicationHelper

      private

      def support_email
        SolidusQuietLogistics.configuration.support_email
      end
    end
  end
end
