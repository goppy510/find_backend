# frozen_string_literal: true

require 'factory_bot_rails'
require 'faker'

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { |n| "password_digest_#{n}" }
    activated { false }
  end
end
