class CreateBills < ActiveRecord::Migration
  def change
    create_table :bills do |t|
      t.date :bill_date, null: false
      t.decimal :total_cost, precision: 10, scale: 2, null: false
      t.boolean :actual, default: false

      t.timestamps
    end

    add_index 'bills', 'bill_date', name: 'index_bills_on_bill_date', unique: true
  end
end
