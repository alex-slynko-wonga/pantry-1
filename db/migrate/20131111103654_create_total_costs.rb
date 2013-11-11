class CreateTotalCosts < ActiveRecord::Migration
  def change
    create_table :total_costs do |t|
      t.decimal :cost, precision: 10, scale: 2
      t.date :bill_date

      t.timestamps
    end
  end
end
