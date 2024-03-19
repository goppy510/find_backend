# frozen_string_literal: true

module Permissions
  class PermissionDomain
    include SessionModule
    include Permissions::PermissionError

    attr_reader :target_user_id,
                :permissions

    def initialize(target_user_id = nil, permissions = [])
      @permissions = permissions if permissions.present?
      @target_user_id = target_user_id if target_user_id.present?

      freeze
    end

    # 権限追加
    def create
      PermissionRepository.create(@target_user_id, @permissions)
    end

    # 権限表示
    def index_all
      PermissionRepository.index_all
    end

    def index
      PermissionRepository.index(@target_user_id)
    end

    # 権限表示
    def show
      PermissionRepository.show(@target_user_id)
    end

    # 権限更新
    def update
      PermissionRepository.update(@target_user_id, @permissions)
    end

    def destroy
      PermissionRepository.destroy(@target_user_id, @permissions)
    end

    class << self
      def create(target_user_id, permissions)
        raise ArgumentError, 'target_user_idがありません' if target_user_id.blank?
        raise ArgumentError, 'permissionsがありません' if permissions.blank?

        domain = new(target_user_id, permissions)
        domain&.create
      end

      def index_all
        domain = Permissions::PermissionDomain.new
        domain&.index_all
      rescue StandardError => e
        Rails.logger.error(e)
        raise e
      end

      def index(target_user_id)
        raise ArgumentError, 'target_user_idがありません' if target_user_id.blank?

        domain = Permissions::PermissionDomain.new(target_user_id)
        domain&.index
      rescue StandardError => e
        Rails.logger.error(e)
        raise e
      end

      def show(target_user_id)
        raise ArgumentError, 'target_user_idがありません' if target_user_id.blank?

        domain = new(target_user_id)
        res = domain&.show
        {
          permissions: res
        }
      end

      def update(target_user_id, permissions)
        raise ArgumentError, 'target_user_idがありません' if target_user_id.blank?
        raise ArgumentError, 'permissionsがありません' if permissions.blank?

        domain = new(target_user_id, permissions)
        domain&.update
      end

      def destroy(target_user_id, permissions)
        raise ArgumentError, 'target_user_idがありません' if target_user_id.blank?
        raise ArgumentError, 'permissionsがありません' if permissions.blank?

        domain = new(target_user_id, permissions)
        domain&.destroy
      end
    end
  end
end
