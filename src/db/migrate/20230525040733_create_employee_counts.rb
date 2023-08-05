class CreateEmployeeCounts < ActiveRecord::Migration[7.0]
  def change
    create_table :employee_counts do |t|
      t.string :name, null: false, unique: true
      t.string :range, null: false, unique: true

      t.timestamps
    end
  end
end