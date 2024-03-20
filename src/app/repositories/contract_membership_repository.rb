# frozen_string_literal: true

class ContractMembershipRepository
  class << self
    def index_all
      ContractMembership.joins(:user, :contract)
                        .select('users.id AS user_id, users.email, users.activated, users.created_at, users.updated_at, contracts.id AS contract_id')
                        .distinct
    end

    def index(target_user_id)
      ContractMembership.joins(:contract, :user)
                        .where(contracts: { user_id: target_user_id })
                        .select('users.id AS user_id, users.email, users.activated, users.created_at, users.updated_at, contracts.id AS contract_id')
    end

    def create(target_user_id)
      ContractMembership.create!(user_id: target_user_id)
    end

    def show(target_user_id)
      ContractMembership.find_by(user_id: target_user_id)
    end

    def destroy(target_user_id)
      ContractMembership.find_by(user_id: target_user_id).destroy!
    end
  end
end
