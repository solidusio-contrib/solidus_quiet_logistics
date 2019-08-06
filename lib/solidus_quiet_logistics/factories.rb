# frozen_string_literal: true

FactoryBot.define do
  factory :ql_message, class: QlMessage do
    document_name { 'document_name' }
    document_type { 'document_type' }

    trait :success do
      success { true }
      processed_at { Time.zone.now }
    end
  end
end
