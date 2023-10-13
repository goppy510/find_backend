# frozen_string_literal: true

class RemoveColumnRoleIdUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :role_id, :integer if column_exists? :users, :role_id
  end
end
