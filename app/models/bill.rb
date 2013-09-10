class Bill < ActiveRecord::Base
  validates :bill_date, uniqueness: true, presence: true
  validates :total_cost, presence: true
end
