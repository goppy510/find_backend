# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# 業種
industry_data = [
  'セールスプロモーション',
  '広告・Web制作・マーケティング支援',
  'Webサービス',
  'メーカー',
  '店舗運営',
  '不動産',
  '人材',
  'その他'
]
industry_data.each do |name|
  Industry.find_or_create_by(name: name)
end

# 従業員数
employee_count_data = [
  { name: '1〜29名', range: 'xs' },
  { name: '30〜49名', range: 'ss' },
  { name: '50〜99名', range: 's' },
  { name: '100〜299名', range: 'm' },
  { name: '300〜599名', range: 'l' },
  { name: '600〜999名', range: 'xl' },
  { name: '1000名以上', range: 'xxl' }
]
employee_count_data.each do |data|
  EmployeeCount.find_or_create_by(data)
end

# 役職
position_data = [
  '経営者/役員',
  '部長',
  '課長/マネージャー',
  '主任',
  '一般社員',
  '代理店/クライアント提案',
  'その他/個人事業主'
]
position_data.each do |name|
  Position.find_or_create_by(name: name)
end

# 事業モデル
business_model_data = [
  'BtoB',
  'BtoC',
  'その他'
]
business_model_data.each do |name|
  BusinessModel.find_or_create_by(name: name)
end

# カテゴリ
category_data = [
  'IT・情報通信業',
  '金融・保険業',
  '不動産業',
  '交通・運輸業',
  '医療・福祉',
  '教育・学習支援業',
  '旅行・宿泊・飲食業',
  'エンターテインメント・マスコミ',
  '広告・マーケティング',
  'コンサルティング業',
  'その他'
]

category_data.each do |name|
  Category.find_or_create_by(name: name)
end

# 生成AIモデル
generative_ai_model_data = [
  'GPT-3.5',
  'GPT-4'
]
generative_ai_model_data.each do |name|
  GenerativeAiModel.find_or_create_by(name: name)
end

# resources
resources_data = [
  'contract',
  'permission',
  'user',
  'create_prompt',
  'read_prompt',
  'update_prompt',
  'destroy_prompt'
]
resources_data.each do |name|
  Resource.find_or_create_by(name: name)
end
