require 'spec_helper'

describe Ec2InstanceCost do
  subject { FactoryGirl.build(:ec2_instance_cost) }
  it { should be_valid }
end
