class CreateAmis < ActiveRecord::Migration
  def change
    create_table :amis do |t|
      t.string :name, null: false
      t.string :platform, null: false
      t.string :ami_id, null: false
      t.boolean :hidden

      t.timestamps
    end
  end
end
