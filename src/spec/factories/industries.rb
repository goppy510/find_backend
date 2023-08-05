# frozen_string_literal: true

require 'factory_bot_rails'
require 'faker'

FactoryBot.define do
  industry_names = [
    'セールスプロモーション',
    '広告・Web制作・マーケティング支援',
    'Webサービス',
    'メーカー',
    '店舗運営',
    '不動産',
    '人材',
    'その他'
  ]

  factory :industry do
    name { industry_names.sample }
  end
end
