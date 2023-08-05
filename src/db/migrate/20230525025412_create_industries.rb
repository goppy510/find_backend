class CreateIndustries < ActiveRecord::Migration[7.0]
  def change
    create_table :industries do |t|
      t.string :name, null: false, unique: true

      t.timestamps
    end

    add_index :industries, :name, unique: true
  end
end
