# frozen_string_literal: true

class CreateDeletedPrompts < ActiveRecord::Migration[7.0]
  def up
    return if table_exists?(:deleted_prompts)

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

      t.datetime :deleted_at, null: false

      t.timestamps
    end

    add_index :deleted_prompts, :uuid, unique: true unless index_exists?(:deleted_prompts, :uuid, unique: true)
    add_index :deleted_prompts, %i[user_id category_id] unless index_exists?(:deleted_prompts, %i[user_id category_id])
    return if index_exists?(:deleted_prompts, %i[contract_id category_id])

    add_index :deleted_prompts, %i[contract_id category_id]
  end

  def down
    remove_index :deleted_prompts, :uuid if index_exists?(:deleted_prompts, :uuid)
    remove_index :deleted_prompts, column: %i[user_id category_id] if index_exists?(:deleted_prompts,
                                                                                    %i[user_id category_id])
    remove_index :deleted_prompts, column: %i[contract_id category_id] if index_exists?(:deleted_prompts,
                                                                                        %i[contract_id category_id])

    drop_table :deleted_prompts
  end
end
