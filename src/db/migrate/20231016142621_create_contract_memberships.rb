# frozen_string_literal: true

class CreateContractMemberships < ActiveRecord::Migration[7.0]
  def change
    create_table :contract_memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :contract, null: false, foreign_key: true

      t.timestamps
    end

    # ユーザーと契約の組み合わせはユニークであるべきなので、ユニーク制約を追加
    add_index :contract_memberships, [:user_id, :contract_id], unique: true
  end
end
