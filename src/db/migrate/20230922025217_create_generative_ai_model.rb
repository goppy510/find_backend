# frozen_string_literal: true

class CreateGenerativeAiModel < ActiveRecord::Migration[7.0]
  def change
    create_table :generative_ai_models do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
