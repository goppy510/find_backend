# frozen_string_literal: true

class CreatePrompts < ActiveRecord::Migration[7.0]
  def change
    create_table :prompts do |t|
      t.string :uuid, null: false
      t.bigint :category_id, foreign_key: true
      t.bigint :contract_id, foreign_key: true, null: true
      t.string :title, null: false
      t.text :about
      t.text :input_example
      t.text :output_example
      t.text :prompt
      t.references :generative_ai_model, foreign_key: true
      t.references :user, foreign_key: { on_delete: :nullify }, null: true
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end

    add_index :prompts, :uuid, unique: true
    add_index :prompts, [:user_id, :deleted, :category_id]
    add_index :prompts, [:deleted, :category_id]
    add_index :prompts, [:contract_id, :deleted, :category_id]
  end
end
