class CreateRating < ActiveRecord::Migration[7.0]
  def change
    create_table :ratings do |t|
      t.references :user, foreign_key: true, null: false
      t.references :prompt, foreign_key: true, null: false

      t.timestamps
    end
  end
end
