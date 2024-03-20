# frozen_string_literal: true

module Members
  class UsersDomain
    include SessionModule
    include Members::UsersError

    attr_reader :contract_id,
                :user_id,
                :target_user_id

    def initialize(target_user_id = nil)
      @target_user_id = target_user_id if target_user_id.present?

      freeze
    end

    def index_all
      ContractMembershipRepository.index_all
    end

    def index
      ContractMembershipRepository.index(@target_user_id)
    end

    def show
      ContractMembershipRepository.show(@target_user_id)
    end

    def destroy
      record = ContractMembershipRepository.show(@target_user_id)
      raise Members::UsersError::Forbidden if record.blank?

      ContractMembershipRepository.destroy(@target_user_id)
    end

    class << self
      def index_all
        domain = Members::UsersDomain.new
        domain&.index_all
      rescue StandardError => e
        Rails.logger.error(e)
        raise e
      end

      def index(target_user_id)
        raise ArgumentError, 'target_user_id がありません' if target_user_id.blank?

        domain = Members::UsersDomain.new(target_user_id)
        domain&.index
      rescue StandardError => e
        Rails.logger.error(e)
        raise e
      end

      def show(target_user_id)
        raise ArgumentError, 'target_user_idがありません' if target_user_id.blank?

        domain = Members::UsersDomain.new(target_user_id)
        domain&.show
      rescue StandardError => e
        Rails.logger.error(e)
        raise e
      end

      def destroy(target_user_id)
        raise ArgumentError, 'target_user_idがありません' if target_user_id.blank?

        domain = Members::UsersDomain.new(target_user_id)
        domain&.destroy
      rescue StandardError => e
        Rails.logger.error(e)
        raise e
      end
    end
  end
end
