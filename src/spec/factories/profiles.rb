# frozen_string_literal: true

require 'factory_bot_rails'
require 'faker'

FactoryBot.define do
  factory :profile do
    association :user
    nickname { Faker::Name.name }
    full_name { Faker::Name.name }
    phone_number { Faker::PhoneNumber.cell_phone }
    company_name { Faker::Company.name }

    after(:build) do |profile|
      profile.employee_count ||=
        EmployeeCount.any? ? EmployeeCount.order(Arel.sql('RAND()')).first : create(:employee_count)
      profile.industry ||=
        Industry.any? ? Industry.order(Arel.sql('RAND()')).first : create(:industry)
      profile.position ||=
        Position.any? ? Position.order(Arel.sql('RAND()')).first : create(:position)
      profile.business_model ||=
        BusinessModel.any? ? BusinessModel.order(Arel.sql('RAND()')).first : create(:business_model)
    end
  end
end
