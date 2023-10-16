# frozen_string_literal: true

class PermissionRepository
  class << self
    def create(user_id, permissions = {})
      # permissions[:resource] から resource_ids を取得します。
      resource = Resource.find_by(name: permissions[:resource])
      return if resource.blank?

      Permission.create!(user_id:, resource_id: resource.id)
    end

    def show(user_id)
      Permission.joins(:resource)
                .where(user_id: user_id)
                .pluck('resources.name')
    end

    def delete(user_id, permissions = {})
      resource = Resource.find_by(name: permissions[:resource])
      Permission.where(user_id: user_id, resource_id: resource.id).destroy_all
    end
  end
end
