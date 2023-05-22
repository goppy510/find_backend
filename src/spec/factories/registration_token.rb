# frozen_string_literal: true

require 'factory_bot_rails'
require 'faker'
require 'securerandom'

FactoryBot.define do
  factory :registration_token do
    sequence(:id) { Faker::Number.between(1,20) }
    sequence(:user_id) { Faker::Number.between(1,20) }
    sequence(:token) { SecureRandom.uuid }
    sequence(:expires_at) { Time.current.in_time_zone + 1.hour }
  end
end
