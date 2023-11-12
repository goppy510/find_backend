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

      raise Contracts::ContractsError::Forbbiden if @contract_id.blank?

      freeze
    end

    def create
      raise Contracts::ContractsError::RecordLimitExceeded if is_limit?

      ContractMembershipRepository.create(@target_user_id, @contract_id)
    rescue ActiveRecord::RecordNotUnique => e
      Rails.logger.error(e)
      raise DuplicateEntry
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error(e)
      raise e
    end

    def show
      ContractMembershipRepository.show(@target_user_id, @contract_id)
    end

    def index
      ContractMembershipRepository.index(@contract_id)
    end

    def destroy
      ContractMembershipRepository.destroy(@target_user_id, @contract_id)
    end

    private

    def is_limit?
      max_member_count = @contract&.max_member_count
      current_count = ContractMembershipRepository.index(@contract_id)&.count || 0
      current_count >= max_member_count
    end
    

    class << self
      def create(user_id, target_user_id)
        raise ArgumentError, 'user_idがありません' if user_id.blank?
        raise ArgumentError, 'target_user_idがありません' if target_user_id.blank?

        domain = Contracts::UsersDomain.new(user_id, target_user_id)
        domain&.create
      rescue StandardError => e
        Rails.logger.error(e)
        raise e
      end

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
