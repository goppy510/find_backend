# frozen_string_literal: true

class CreateContracts < ActiveRecord::Migration[6.1]
  def change
    create_table :contracts do |t|
      t.references :admin_user, null: false, foreign_key: { to_table: :users }
      t.integer :max_member_count, null: false
      
      t.timestamps
    end
  end
end