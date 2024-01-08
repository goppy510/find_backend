# frozen_string_literal: true

class ContractService
  class << self
    include SessionModule
    include Contracts::ContractsError

    def create(token, target_user_id, max_member_count)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'target_user_idがありません' if target_user_id.blank?
      raise ArgumentError, 'max_member_countがありません' if max_member_count.blank?

      user_id = authenticate_user(token)[:user_id]
      if !PermissionService.has_contract_role?(user_id) && !PermissionService.has_admin_role?(user_id)
        raise Contracts::ContractsError::Forbidden
      end

      Contracts::ContractDomain.create(target_user_id, max_member_count)
    rescue StandardError => e
      Rails.logger.error(e)
      raise e
    end

    def show(token, target_user_id)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'target_user_idがありません' if target_user_id.blank?

      user_id = authenticate_user(token)[:user_id]
      if !PermissionService.has_contract_role?(user_id) && !PermissionService.has_admin_role?(user_id)
        raise Contracts::ContractsError::Forbidden
      end

      contract = Contracts::ContractDomain.show(target_user_id)
      return nil if contract.blank?

      user = UserRepository.find_by_id(target_user_id)
      return nil if user.blank?

      res = {
        user_id: user.id,
        email: user.email,
        activated: user.activated,
        contract_id: contract.id,
        max_member_count: contract.max_member_count,
        created_at: contract.created_at.strftime('%Y-%m-%d %H:%M:%S'),
        updated_at: contract.updated_at.strftime('%Y-%m-%d %H:%M:%S')
      }
      return res
    rescue StandardError => e
      Rails.logger.error(e)
      raise e
    end

    def index(token)
      raise ArgumentError, 'tokenがありません' if token.blank?

      user_id = authenticate_user(token)[:user_id]
      if !PermissionService.has_contract_role?(user_id) && !PermissionService.has_admin_role?(user_id)
        raise Contracts::ContractsError::Forbidden
      end

      contracts = Contracts::ContractDomain.index
      return nil if contracts.blank?

      response = contracts.map do |contract|
        user = contract.user
        {
          user_id: user.id,
          email: user.email,
          activated: user.activated,
          contract_id: contract.id,
          max_member_count: contract.max_member_count,
          created_at: contract.created_at.strftime('%Y-%m-%d %H:%M:%S'),
          updated_at: contract.updated_at.strftime('%Y-%m-%d %H:%M:%S')
        }
      end
      response
    rescue StandardError => e
      Rails.logger.error(e)
      raise e
    end

    def update(token, target_user_id, max_member_count)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'target_user_idがありません' if target_user_id.blank?
      raise ArgumentError, 'max_member_countがありません' if max_member_count.blank?

      user_id = authenticate_user(token)[:user_id]
      if !PermissionService.has_contract_role?(user_id) && !PermissionService.has_admin_role?(user_id)
        raise Contracts::ContractsError::Forbidden
      end

      Contracts::ContractDomain.update(target_user_id, max_member_count)
    rescue StandardError => e
      Rails.logger.error(e)
      raise e
    end

    def destroy(token, target_user_id)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'target_user_idがありません' if target_user_id.blank?

      user_id = authenticate_user(token)[:user_id]
      if !PermissionService.has_contract_role?(user_id) && !PermissionService.has_admin_role?(user_id)
        raise Contracts::ContractsError::Forbidden
      end

      Contracts::ContractDomain.destroy(target_user_id)
    rescue StandardError => e
      Rails.logger.error(e)
      raise e
    end
  end
end
