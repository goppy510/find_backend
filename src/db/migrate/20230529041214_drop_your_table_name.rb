class DropYourTableName < ActiveRecord::Migration[6.0]
  def up
    drop_table :registration_tokens
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
