# frozen_string_literal: true

require 'factory_bot_rails'
require 'faker'

FactoryBot.define do
  employee_count_data = [
    { name: '1〜29名', range: 'xs' },
    { name: '30〜49名', range: 'ss' },
    { name: '50〜99名', range: 's' },
    { name: '100〜299名', range: 'm' },
    { name: '300〜599名', range: 'l' },
    { name: '600〜999名', range: 'xl' },
    { name: '1000名以上', range: 'xxl' }
  ]

  factory :employee_count do
    selected_data = employee_count_data.sample
    name { selected_data[:name] }
    range { selected_data[:range] }
    created_at { Time.zone.now }
    updated_at { Time.zone.now }
  end
end
