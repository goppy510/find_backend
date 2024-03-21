# frozen_string_literal: true

class CreateDeletedUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :deleted_users do |t|
      t.string :email, null: false
      t.string :password_digest
      t.boolean :activated, default: false, null: false

      t.datetime :deleted_at, null: false # 削除日時を追加

      t.timestamps
    end

    add_index :deleted_users, :email
    add_index :deleted_users, :activated
  end
end
