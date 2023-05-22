# frozen_string_literal: true

require 'factory_bot_rails'
require 'faker'
require 'securerandom'
require 'digest'

FactoryBot.define do
  random_string = Faker::Lorem.sentence
  sha256_hash = Digest::SHA256.hexdigest(random_string)
  factory :registration_token do
    association :user, email: Faker::Internet.email, password_digest: sha256_hash
    token { SecureRandom.uuid }
    expires_at { Time.current.in_time_zone + 1.hour }
  end
end
