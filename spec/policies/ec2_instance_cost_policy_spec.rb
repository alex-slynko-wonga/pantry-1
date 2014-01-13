require 'spec_helper'

describe Ec2InstanceCostPolicy do
  context "for business_admin" do
    subject { Ec2InstanceCostPolicy.new(User.new(role: 'business_admin'), Ec2InstanceCost.new) }

    it { should permit(:index?) }
  end

  context "for superadmin" do
    subject { Ec2InstanceCostPolicy.new(User.new(role: 'superadmin'), Ec2InstanceCost.new) }
    it { should permit(:index?) }
  end
end

