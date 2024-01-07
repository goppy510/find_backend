# frozen_string_literal: true

class AddUniqueIndexToContractsUserId < ActiveRecord::Migration[7.0]
  def change
    # contractsテーブルのuser_idカラムにユニークインデックスを追加
    add_index :contracts, :user_id, unique: true, name: 'unique_on_user_id'
  end
end
