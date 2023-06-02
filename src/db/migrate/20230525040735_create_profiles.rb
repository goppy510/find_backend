class CreateProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :profiles do |t|
      t.bigint :user_id, null: false
      t.string :full_name, null: false
      t.string :phone_number, null: false, unique: true
      t.string :company_name, null: false
      t.references :employee_count, null: false, foreign_key: { to_table: :employee_counts, column: :employee_count_id }
      t.references :industry, null: false, foreign_key: { to_table: :industries }
      t.references :position, null: false, foreign_key: { to_table: :positions }
      t.references :business_model, null: false, foreign_key: { to_table: :business_models }

      t.timestamps
    end

    add_index :profiles, :full_name
    add_index :profiles, :company_name
    add_index :profiles, :phone_number
    add_foreign_key :profiles, :users, column: :user_id
  end
end
