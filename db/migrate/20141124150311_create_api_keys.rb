class CreateApiKeys < ActiveRecord::Migration
  def change
    create_table :api_keys do |t|
      t.string :name
      t.string :key
      t.text :permissions

      t.timestamps
    end
  end
end
