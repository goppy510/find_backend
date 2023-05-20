# frozen_string_literal: true

require 'factory_bot_rails'
require 'faker'

FactoryBot.define do
  factory :user do
    sequence(:id) { Faker::Number.between(1,20) }
    sequence(:email) { Faker::Internet.email }
    sequence(:password_digest) { |n| "password_digest_#{n}" }
    sequence(:confirmed) { false }
  end
end
