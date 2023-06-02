# frozen_string_literal: true

require 'factory_bot_rails'
require 'faker'

FactoryBot.define do
  position_names = [
    '経営者/役員',
    '部長',
    '課長/マネージャー',
    '主任',
    '一般社員',
    '代理店/クライアント提案',
    'その他/個人事業主'
  ]

  factory :position do
    name { position_names.sample }
  end
end
