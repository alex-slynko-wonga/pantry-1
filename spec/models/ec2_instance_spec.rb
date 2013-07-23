require 'spec_helper'

describe Ec2Instance do
  subject { FactoryGirl.build :ec2_instance }
  it { should be_valid }
end
