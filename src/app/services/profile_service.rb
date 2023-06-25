# frozen_string_literal: true

class ProfileService
  include SessionModule

  attr_reader :name,
              :profiles,
              :password

  def initialize(user_id, profiles: {}, password: nil)
    @user_id = user_id
    @password = password if password.present?
    @profiles = {}
    @profiles[:name] = Account::Name.from_string(profiles[:name]) if profiles.key?(:name)
    @profiles[:phone_number] = Account::PhoneNumber.from_string(profiles[:phone_number]) if profiles.key?(:phone_number)
    @profiles[:company_name] = Account::CompanyName.from_string(profiles[:company_name]) if profiles.key?(:company_name)
    # 以下、ラジオボタンの数値なのでバリデーションしない
    @profiles[:employee_count] = profiles[:employee_count] if profiles.key?(:employee_count)
    @profiles[:industry] = profiles[:industry] if profiles.key?(:industry)
    @profiles[:position] = profiles[:position] if profiles.key?(:position)
    @profiles[:business_model] = profiles[:business_model] if profiles.key?(:business_model)

    self.freeze
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
    def create(token, profiles)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'profilesがありません', if profiles.empty?
      required_keys = [
        :name,
        :phone_number,
        :company_name,
        :employee_count,
        :industry,
        :position,
        :business_model
      ]
      required_keys.each { |key| hash.fetch(key) { raise KeyError, "Key #{key} が見つかりませんでした" } }

      service = new(token, profiles: profiles)
      service&.create
    end

    def edit(token, profiles: {})
      raise ArgumentError, 'tokenがありません' if token.blank?

      service = new(token, profiles)
      service&.edit
    end

    def update_password(token, passwodd: password)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'passwordがありません' if password.blank?
      service = new(token, password)
      service&.update_password
    end
  end
end

class Unauthorized < StandardError; end
