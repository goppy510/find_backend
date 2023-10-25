# frozen_string_literal: true

class ProfileRepository
  class << self
    def create(user_id, profiles = {})
      # ラジオボタンのvalueは各テーブルのidに対応
      employee_count = EmployeeCount.find(profiles[:employee_count])
      industry = Industry.find(profiles[:industry])
      position = Position.find(profiles[:position])
      business_model = BusinessModel.find(profiles[:business_model])

      Profile.create!(
        user_id:,
        full_name: profiles[:name],
        nickname: profiles[:nickname],
        phone_number: profiles[:phone_number],
        company_name: profiles[:company_name],
        employee_count_id: employee_count.id,
        industry_id: industry.id,
        position_id: position.id,
        business_model_id: business_model.id
      )
    end

    def update_profiles(user_id, profiles = {})
      updates = {}
      updates[:employee_count_id] = EmployeeCount.find(profiles[:employee_count]).id if profiles.key?(:employee_count)
      updates[:industry_id] = Industry.find(profiles[:industry]).id if profiles.key?(:industry)
      updates[:position_id] = Position.find(profiles[:position]).id if profiles.key?(:position)
      updates[:business_model_id] = BusinessModel.find(profiles[:business_model]).id if profiles.key?(:business_model)
      # 残りのフィールドは直接更新します
      updates[:full_name] = profiles[:name] if profiles.key?(:name)
      updates[:nickname] = profiles[:nickname] if profiles.key?(:nickname)
      updates[:phone_number] = profiles[:phone_number] if profiles.key?(:phone_number)
      updates[:company_name] = profiles[:company_name] if profiles.key?(:company_name)
      Profile.where(user_id:).update!(updates)
    end

    def show(user_id)
      Profile.find_by(user_id:)
    end

    def find_by_user_id(user_id)
      Profile.find_by(user_id:)
    end
  end
end
