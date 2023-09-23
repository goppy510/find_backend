# frozen_string_literal: true

class AddColumnNickNameForProfile < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :nickname, :string, after: :user_id, null: false

    add_index :profiles, :nickname
  end
end
