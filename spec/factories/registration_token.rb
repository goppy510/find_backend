# frozen_string_literal: true

require 'factory_bot_rails'
require 'faker'

FactoryBot.define do
  factory :registration_token do
    sequence(:id) { Faker::Number.between(1,20) }
    sequence(:user_id) { Faker::Number.between(1,20) }
    sequence(:expires_at) { |n| "password_digest_#{n}" }
  end
end
