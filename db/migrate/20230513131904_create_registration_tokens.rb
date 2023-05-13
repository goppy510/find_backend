class CreateRegistrationTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :registration_tokens do |t|
      t.references :user, foreign_key: true
      t.string :token
      t.datetime :expires_at

      t.timestamps
    end
  end
end
