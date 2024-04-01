# frozen_string_literal: true

class RenameAboutToDescriptionInPrompts < ActiveRecord::Migration[7.0]
  def change
    # aboutカラムをdescriptionに名前変更する
    rename_column :prompts, :about, :description
  end
end
