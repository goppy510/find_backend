# frozen_string_literal: true

class ProfileService
  include SessionModule

  attr_reader :name,
              :profiles,
              :password

  def initialize(token, profiles: nil, current_password: nil, new_password: nil)
    hash_profiles = profiles[:profiles] if profiles.present?
    @user_id = authenticate_user(token)[:user_id]
    @current_password = current_password if current_password.present?
    @new_password = new_password if new_password.present?
    @profiles = {}
    @profiles[:name] = Account::Name.from_string(hash_profiles[:name]) if hash_profiles&.key?(:name)
    if hash_profiles&.key?(:phone_number)
      @profiles[:phone_number] = Account::PhoneNumber.from_string(hash_profiles[:phone_number])
    end
    if hash_profiles&.key?(:company_name)
      @profiles[:company_name] = Account::CompanyName.from_string(hash_profiles[:company_name])
    end
    # 以下、ラジオボタンの数値なのでバリデーションしない
    @profiles[:employee_count] = hash_profiles[:employee_count] if hash_profiles&.key?(:employee_count)
    @profiles[:industry] = hash_profiles[:industry] if hash_profiles&.key?(:industry)
    @profiles[:position] = hash_profiles[:position] if hash_profiles&.key?(:position)
    @profiles[:business_model] = hash_profiles[:business_model] if hash_profiles&.key?(:business_model)

    freeze
  end

  # プロフィール新規作成
  def create
    ProfileRepository.create(@user_id, @profiles)
  end

  # プロフィール更新
  def update_profiles
    ProfileRepository.update_profiles(@user_id, @profiles)
  end

  # パスワード更新
  def update_password
    ProfileRepository.update_password(@user_id, @current_password, @new_password)
  end

  # プロファイル表示
  def show
    ProfileRepository.show(@user_id)
  end

  class << self
    def create(token, profiles)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'profilesがありません' if profiles.blank?

      service = new(token, profiles:)
      service&.create
    end

    def update_profiles(token, profiles)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'profilesがありません' if profiles.blank?

      service = new(token, profiles:)
      service&.update_profiles
    end

    def update_password(token, current_password, new_password)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'current_passwordがありません' if current_password.blank?
      raise ArgumentError, 'new_passwordがありません' if new_password.blank?

      service = new(token, current_password:, new_password:)
      service&.update_password
    rescue StandardError => e
      Rails.logger.error e
      raise e
    end

    def show(token)
      raise ArgumentError, 'tokenがありません' if token.blank?

      res = new(token)&.show
      {
        user_id: res[:user_id],
        name: res[:full_name],
        phone_number: res[:phone_number],
        company_name: res[:company_name],
        employee_count: EmployeeCount.find(res[:employee_count_id]).name,
        industry: Industry.find(res[:industry_id]).name,
        position: Position.find(res[:position_id]).name,
        business_model: BusinessModel.find(res[:business_model_id]).name
      }
    end
  end
end

class Unauthorized < StandardError; end
