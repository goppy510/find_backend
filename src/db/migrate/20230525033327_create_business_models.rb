class CreateBusinessModels < ActiveRecord::Migration[7.0]
  def change
    create_table :business_models do |t|
      t.string :name, null: false, unique: true

      t.timestamps
    end
    add_index :business_models, :name
  end
end
