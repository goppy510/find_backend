# frozen_string_literal: true

class PermissionService
  include SessionModule

  class Forbidden < StandardError; end

  attr_reader :user_id,
              :target_user_id,
              :permissions

  def initialize(token,  permissions: {})
    permission = permissions[:permissions][:resource] if permissions.present? && permissions[:permissions].present? && permissions[:permissions][:resource].present?
    @target_user_id = permissions[:permissions][:target_user_id] if permissions.present? && permissions[:permissions].present? && permissions[:permissions][:target_user_id].present?
    @user_id = authenticate_user(token)[:user_id]

    @permissions = {}
    @permissions[:resource] = permission

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

  def delete
    PermissionRepository.delete(@target_user_id, @permissions)
  end

  # 自分の権限表示
  def self_permission
    PermissionRepository.show(@user_id)
  end

  class << self
    def create(token, permissions)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'permissionsがありません' if permissions.blank?
      raise Forbidden unless has_permisssion_role?(token)

      service = new(token, permissions:)
      service&.create
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

    def delete(token, permissions)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'permissionsがありません' if permissions.blank?
      raise Forbidden unless has_permisssion_role?(token)

      service = new(token, permissions:)
      service&.delete
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
