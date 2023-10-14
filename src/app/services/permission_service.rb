# frozen_string_literal: true

class PermissionService
  include SessionModule

  attr_reader :name,
              :permissions

  def initialize(token, permissions: nil)
    array_permissions = permissions[:permissions][:resource] if permissions.present? && permissions[:permissions].present? && permissions[:permissions][:resource].present?
    @user_id = authenticate_user(token)[:user_id]

    @permissions = {}
    @permissions[:resource] = array_permissions

    freeze
  end

  # 権限追加
  def upsert
    PermissionRepository.upsert(@user_id, @permissions)
  end

  # 権限表示
  def show
    PermissionRepository.show(@user_id)
  end

  class << self
    def upsert(token, permissions)
      raise ArgumentError, 'tokenがありません' if token.blank?
      raise ArgumentError, 'permissionsがありません' if permissions.blank?

      service = new(token, permissions:)
      service&.upsert
    end

    def show(token)
      raise ArgumentError, 'tokenがありません' if token.blank?

      res = new(token)&.show
      {
        resource: res
      }
    end

    def has_contract?(token)
      raise ArgumentError, 'tokenがありません' if token.blank?

      new(token)&.show.include?('contract')
    end
  end
end
