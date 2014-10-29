require 'spec_helper'

RSpec.describe Ec2AdapterPolicy do
  subject { described_class.new(user) }

  context 'when user is admin' do
    let(:user) { FactoryGirl.build(:superadmin) }
    it { is_expected.to permit(:show_all_security_groups?) }
    it { is_expected.to permit(:show_all_subnets?) }
  end

  context 'when user is not an admin' do
    let(:user) { FactoryGirl.build(:user) }
    it { is_expected.not_to permit(:show_all_security_groups?) }
    it { is_expected.not_to permit(:show_all_subnets?) }
  end
end
