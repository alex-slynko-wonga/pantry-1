class Ec2InstanceCost < ActiveRecord::Base
  belongs_to :ec2_instance

  validates :ec2_instance, presence: true
  validates :bill_date, presence: true, uniqueness: { scope: :ec2_instance_id }
  validates :cost, presence: true

  def self.available_dates
    Ec2InstanceCost.uniq.order('bill_date DESC').pluck(:bill_date)
  end
end
