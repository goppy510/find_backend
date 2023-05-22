# frozen_string_literal: true

require 'factory_bot_rails'
require 'faker'

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password_digest { |n| "password_digest_#{n}" }
    confirmed { false }
  end
end
