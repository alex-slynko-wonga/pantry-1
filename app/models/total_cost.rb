class TotalCost < ActiveRecord::Base
  validates :cost, presence: true
  validates :bill_date, presence: true, uniqueness: true
end
