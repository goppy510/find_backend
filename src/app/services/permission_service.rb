# frozen_string_literal: true

class PermissionService
  include SessionModule

  class Forbidden < StandardError; end

  attr_reader :user_id,
              :target_user_id,
              :permissions

  def initialize(token,  permissions: {})
    array_permissions = permissions[:permissions][:resource] if permissions.present? && permissions[:permissions].present? && permissions[:permissions][:resource].present?
    @target_user_id = permissions[:permissions][:target_user_id] if permissions.present? && permissions[:permissions].present? && permissions[:permissions][:target_user_id].present?
    @user_id = authenticate_user(token)[:user_id]

    @permissions = {}
    @permissions[:resource] = array_permissions

    freeze
  end

  # 権限追加
  def upsert
    PermissionRepository.upsert(@target_user_id, @permissions)
  end

  # 権限表示
  def show
    PermissionRepository.show(@target_user_id)
  end

  # 自分の権限表示
  def self_permission
    PermissionRepository.show(@user_id)
  end

  class << self
    def upsert(token, permissions)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'permissionsがありません' if permissions.blank?
      raise Forbidden unless has_permisssion_role?(token)

      service = new(token, permissions:)
      service&.upsert
    end

    def show(token, permissions)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'permissionsがありません' if permissions.blank? || permissions[:permissions][:target_user_id].blank?
      raise Forbidden unless has_permisssion_role?(token)

      res = new(token, permissions:)&.show
      {
        resource: res
      }
    end

    def has_contract_role?(token)
      raise ArgumentError, 'tokenがありません' if token.blank?

      new(token)&.self_permission.include?('contract')
    end

    def has_permisssion_role?(token)
      raise ArgumentError, 'tokenがありません' if token.blank?

      new(token)&.self_permission.include?('permission')
    end

    def has_user_role?(token)
      raise ArgumentError, 'tokenがありません' if token.blank?

      new(token)&.self_permission.include?('user')
    end
  end
end
