# frozen_string_literal: true

class ProfileService
  include SessionModule

  attr_reader :name,
              :profiles,
              :password

  def initialize(user_id, profiles: nil, password: nil)
    hash_profiles = profiles[:profiles]
    @user_id = user_id
    @password = password if password.present?
    @profiles = {}
    @profiles[:name] = Account::Name.from_string(hash_profiles[:name]) if hash_profiles.key?(:name)
    if hash_profiles.key?(:phone_number)
      @profiles[:phone_number] = Account::PhoneNumber.from_string(hash_profiles[:phone_number])
    end
    if hash_profiles.key?(:company_name)
      @profiles[:company_name] = Account::CompanyName.from_string(hash_profiles[:company_name])
    end
    # 以下、ラジオボタンの数値なのでバリデーションしない
    @profiles[:employee_count] = hash_profiles[:employee_count] if hash_profiles.key?(:employee_count)
    @profiles[:industry] = hash_profiles[:industry] if hash_profiles.key?(:industry)
    @profiles[:position] = hash_profiles[:position] if hash_profiles.key?(:position)
    @profiles[:business_model] = hash_profiles[:business_model] if hash_profiles.key?(:business_model)

    freeze
  end

  # プロフィール新規作成
  def create
    ProfileRepository.create(@user_id, @profiles)
  end

  # プロフィール更新
  def edit
    ProfileRepository.edit(@user_id, @profiles)
  end

  # パスワード更新
  def update_password
    ProfileRepository.update_service(@user_id, @password)
  end

  class << self
    def create(user_id, profiles)
      raise ArgumentError, 'user_idがありません' if user_id.blank?
      raise ArgumentError, 'profilesがありません' if profiles.blank?

      service = new(user_id, profiles:)
      service&.create
    end

    def edit(token, profiles: {})
      raise ArgumentError, 'tokenがありません' if token.blank?

      service = new(token, profiles)
      service&.edit
    end

    def update_password(token, password:)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'passwordがありません' if password.blank?

      service = new(token, password)
      service&.update_password
    end
  end
end

class Unauthorized < StandardError; end
