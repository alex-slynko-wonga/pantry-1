class Ec2Instance < ActiveRecord::Base
  attr_accessible :instance_id, :name, :status
end
