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
        phone_number: profiles[:phone_number],
        company_name: profiles[:company_name],
        employee_count:,
        industry:,
        position:,
        business_model:
      )
    end

    def find_by_user_id(user_id)
      Profile.find_by(user_id:)
    end
  end
end
