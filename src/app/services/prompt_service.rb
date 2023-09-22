# frozen_string_literal: true

class PromptService
  include SessionModule

  attr_reader :user_id,
              :prompts,

  def initialize(token, prompts: nil)
    hash_prompts = prompts[:prompts] if prompts.present?
    @user_id = authenticate_user(token)[:user_id]


    @prompts = {}
    @prompts[:about] = Prompt::About.from_string(hash_profiles[:name]) if hash_profiles&.key?(:name)
    if hash_profiles&.key?(:input_example)
      @prompts[:input_example] = Prompt::InputExample.from_string(hash_profiles[:input_example])
    end
    if hash_profiles&.key?(:output_example)
      @prompts[:output_example] = Prompt::OutputExample.from_string(hash_profiles[:output_example])
    end
    if hash_profiles&.key?(:prompt)
      @prompts[:prompt] = Prompt::Prompt.from_string(hash_profiles[:prompt])
    end
    # 以下、ラジオボタンの数値なのでバリデーションしない
    @prompts[:category] = hash_prompts[:category] if hash_prompts&.key?(:category)
    @prompts[:generative_ai_model] = hash_prompts[:generative_ai_model] if hash_prompts&.key?(:generative_ai_model)

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
