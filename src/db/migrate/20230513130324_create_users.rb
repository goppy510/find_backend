class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest
      t.boolean :confirmed, default: false, null: false

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :confirmed
  end
end
