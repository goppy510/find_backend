# frozen_string_literal: true

module Permissions
  class PermissionDomain
    include SessionModule
    include Permissions::PermissionError

    attr_reader :target_user_id,
                :permissions

    def initialize(target_user_id,  permissions = [])
      @permissions = permissions if permissions.present?
      @target_user_id = target_user_id if target_user_id.present?

      freeze
    end

    # 権限追加
    def create
      PermissionRepository.create(@target_user_id, @permissions)
    end

    # 権限表示
    def show
      PermissionRepository.show(@target_user_id)
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

      def show(target_user_id)
        raise ArgumentError, 'target_user_idがありません' if target_user_id.blank?

        domain = new(target_user_id)
        res = domain&.show
        {
          permissions: res
        }
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
