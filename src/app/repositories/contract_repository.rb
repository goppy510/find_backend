# frozen_string_literal: true

class ContractRepository
  class << self
    def create(user_id, max_member_count = 5)
      user = User.find_by(id: user_id)
      return if user.blank?

      Contract.create!(user_id: user.id, max_member_count: max_member_count)
    end

    def show_one(user_id)
      user = User.find_by(id: user_id)
      return if user.blank?

      Contract.find_by(user_id: user.id)
    end

    def show_all
      Contract.all.order(:id)
    end

    def delete(user_id)
      user = User.find_by(id: user_id)
      return if user.blank?

      Contract.find_by(user_id: user.id).destroy
    end
  end
end
