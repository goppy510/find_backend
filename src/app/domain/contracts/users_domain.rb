# frozen_string_literal: true

module Contracts
  class UsersDomain
    include SessionModule
    include Contracts::ContractsError

    attr_reader :contract_id,
                :user_id,
                :target_user_id

    def initialize(user_id, target_user_id = nil)
      @user_id = user_id if user_id.present?
      @target_user_id = target_user_id if target_user_id.present?
      @contract = ContractRepository.show(@user_id) if @user_id.present?
      @contract_id = @contract&.id

      raise Contracts::ContractsError::Forbidden if @contract_id.blank?

      freeze
    end

    def show
      ContractMembershipRepository.show(@target_user_id, @contract_id)
    end

    def index
      ContractMembershipRepository.index(@contract_id)
    end

    def all_user_permissions
      PermissionRepository.index(@contract_id)
    end

    def destroy
      record = ContractMembershipRepository.show(@target_user_id, @contract_id)
      raise Contracts::ContractsError::Forbidden if record.blank?

      ContractMembershipRepository.destroy(@target_user_id, @contract_id)
    end

    class << self
      def show(user_id, target_user_id)
        raise ArgumentError, 'user_idがありません' if user_id.blank?
        raise ArgumentError, 'target_user_idがありません' if target_user_id.blank?

        domain = Contracts::UsersDomain.new(user_id, target_user_id)
        domain&.show
      rescue StandardError => e
        Rails.logger.error(e)
        raise e
      end

      def index(user_id)
        raise ArgumentError, 'user_idがありません' if user_id.blank?

        domain = Contracts::UsersDomain.new(user_id)
        domain&.index
      rescue StandardError => e
        Rails.logger.error(e)
        raise e
      end

      def destroy(user_id, target_user_id)
        raise ArgumentError, 'user_idがありません' if user_id.blank?
        raise ArgumentError, 'target_user_idがありません' if target_user_id.blank?

        domain = Contracts::UsersDomain.new(user_id, target_user_id)
        domain&.destroy
      rescue StandardError => e
        Rails.logger.error(e)
        raise e
      end
    end
  end
end
