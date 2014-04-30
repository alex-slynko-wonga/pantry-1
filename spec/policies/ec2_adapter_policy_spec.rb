require 'spec_helper'

describe Ec2AdapterPolicy do
  subject { described_class.new(user) }

  context "when user is admin" do
    let(:user) { FactoryGirl.build(:superadmin) }
    it { should permit(:show_all_security_groups?) }
  end

  context "when user is not an admin" do
    let(:user) { FactoryGirl.build(:user) }
    it { should_not permit(:show_all_security_groups?) }
  end
end
