# frozen_string_literal: true

module Contracts
  class ContractDomain
    include SessionModule
    include Contracts::ContractsError

    attr_reader :contract_id,
                :user_id,
                :target_user_id

    def initialize(target_user_id = nil, max_member_count = nil)
      @target_user_id = target_user_id if target_user_id.present?
      @max_member_count = max_member_count if max_member_count.present?

      freeze
    end

    def create
      ContractRepository.create(@target_user_id, @max_member_count)
    end

    def show
      res = ContractRepository.show(@target_user_id)
      {
        contract: res
      }
    end

    def index
      res = ContractRepository.index
      {
        contracts: res
      }
    end

    def update
      ContractRepository.update(@target_user_id, @max_member_count)
    end

    def destroy
      ContractRepository.destroy(@target_user_id)
    end

    class << self
      def create(target_user_id, max_member_count)
        raise ArgumentError, 'target_user_idがありません' if target_user_id.blank?
        raise ArgumentError, 'max_member_countがありません' if max_member_count.blank?

        domain = Contracts::ContractDomain.new(target_user_id, max_member_count)
        domain&.create
      rescue StandardError => e
        Rails.logger.error(e)
        raise e
      end

      def show(target_user_id)
        raise ArgumentError, 'target_user_idがありません' if target_user_id.blank?

        domain = Contracts::ContractDomain.new(target_user_id)
        domain&.show
      rescue StandardError => e
        Rails.logger.error(e)
        raise e
      end

      def index
        domain = Contracts::ContractDomain.new
        domain&.index
      rescue StandardError => e
        Rails.logger.error(e)
        raise e
      end

      def update(target_user_id, max_member_count)
        raise ArgumentError, 'target_user_idがありません' if target_user_id.blank?
        raise ArgumentError, 'max_member_countがありません' if max_member_count.blank?

        domain = Contracts::ContractDomain.new(target_user_id, max_member_count)
        domain&.update
      rescue StandardError => e
        Rails.logger.error(e)
        raise e
      end

      def destroy(target_user_id)
        raise ArgumentError, 'target_user_idがありません' if target_user_id.blank?

        domain = Contracts::ContractDomain.new(target_user_id)
        domain&.destroy
      rescue StandardError => e
        Rails.logger.error(e)
        raise e
      end
    end
  end
end
