# frozen_string_literal: true

class ContractRepository
  class << self
    def create(user_id, max_member_count = 5)
      user = User.find_by(id: user_id)
      return if user.blank?

      Contract.create!(user_id: user.id, max_member_count: max_member_count)
    end

    def show(user_id)
      user = User.find_by(id: user_id)
      return if user.blank?

      Contract.find_by(user_id: user.id)
    end

    def index
      Contract.includes(:user).order(:id)
    end

    def update(user_id, max_member_count)
      user = User.find_by(id: user_id)
      return if user.blank?

      contract = Contract.find_by(user_id: user.id)
      return if contract.blank?

      contract.update!(max_member_count: max_member_count)
    end

    def destroy(user_id)
      user = User.find_by(id: user_id)
      return if user.blank?

      Contract.find_by(user_id: user.id).destroy
    end
  end
end
