# frozen_string_literal: true

module Profiles
  class ProfileDomain
    include SessionModule

    attr_reader :user_id,
                :profiles
  
    def initialize(user_id, profiles: nil)
      hash_profiles = profiles[:profiles] if profiles.present?
      @user_id = user_id
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
    def update
      ProfileRepository.update(@user_id, @profiles)
    end
  
    class << self
      def create(user_id, profiles)
        raise ArgumentError, 'user_idがありません' if user_id.blank?
        raise ArgumentError, 'profilesがありません' if profiles.blank?

        domain = ProfileDomain.new(user_id, profiles:)
        domain&.create
      end
  
      def update(user_id, profiles)
        raise ArgumentError, 'user_idがありません' if user_id.blank?
        raise ArgumentError, 'profilesがありません' if profiles.blank?
  
        domain = ProfileDomain.new(user_id, profiles:)
        domain&.update
      end
  
      def show(user_id)
        raise ArgumentError, 'user_idがありません' if user_id.blank?
  
        res = ProfileRepository.show(user_id)
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
end
