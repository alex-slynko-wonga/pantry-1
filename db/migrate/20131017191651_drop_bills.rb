class DropBills < ActiveRecord::Migration
  def up
    drop_table :bills
  end

  def down
    create_table :bills do |t|
      t.date :bill_date, null: false
      t.decimal :total_cost, precision: 10, scale: 2, null: false
      t.boolean :actual, default: false

      t.timestamps
    end

    add_index "bills", "bill_date", :name => "index_bills_on_bill_date", :unique => true
  end
end
