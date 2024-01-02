# frozen_string_literal: true

class ContractMembershipRepository
  class << self
    def create(target_user_id, contract_id)
      ContractMembership.create!(user_id: target_user_id, contract_id: contract_id)
    end

    def show(target_user_id, contract_id)
      ContractMembership.find_by(user_id: target_user_id, contract_id: contract_id)
    end

    def index(contract_id)
      ContractMembership.where(contract_id: contract_id)
    end

    def destroy(target_user_id, contract_id)
      ContractMembership.find_by(user_id: target_user_id, contract_id: contract_id).destroy!
    end
  end
end
