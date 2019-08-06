# frozen_string_literal: true

namespace :ql_message do
  desc 'Manage the quiet logistics messages'

  task cancel_old_messages: :environment do
    QlMessage.where('created_at > ?', 90.days.ago)
      .where(success: true).destroy_all
  end
end
