class Ec2InstanceLog < ActiveRecord::Base
  belongs_to :ec2_instance
  belongs_to :user

  scope :sorted, -> { order(:created_at) }
end
