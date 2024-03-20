# frozen_string_literal: true

class CreateDeletedPrompts < ActiveRecord::Migration[7.0]
  def change
    create_table :deleted_prompts do |t|
      t.string :uuid, null: false
      t.bigint :category_id, foreign_key: true
      t.bigint :contract_id, foreign_key: true, null: true
      t.string :title, null: false
      t.text :about
      t.text :input_example
      t.text :output_example
      t.text :prompt
      t.references :generative_ai_model, foreign_key: true
      t.references :user, foreign_key: true, null: true

      t.datetime :deleted_at, null: false # 削除日時を追加

      t.timestamps
    end

    add_index :deleted_prompts, :uuid, unique: true
    add_index :deleted_prompts, %i[user_id category_id]
    add_index :deleted_prompts, %i[contract_id category_id]
  end
end
