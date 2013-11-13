class Ec2InstanceLog < ActiveRecord::Base
  belongs_to :ec2_instance
  belongs_to :user
end
