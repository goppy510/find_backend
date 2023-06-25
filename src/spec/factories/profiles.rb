# frozen_string_literal: true

require 'factory_bot_rails'
require 'faker'

FactoryBot.define do
  factory :profile do
    association :user
    full_name { Faker::Name.name }
    phone_number { Faker::PhoneNumber.cell_phone }
    company_name { Faker::Company.name }
    association :employee_count
    association :industry
    association :position
    association :business_model
  end
end
