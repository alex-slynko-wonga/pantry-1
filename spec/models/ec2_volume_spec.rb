RSpec.describe Ec2Volume, type: :model do
  subject { FactoryGirl.build(:ec2_volume) }

  context 'when both instance role and ec2 instance are set' do
    subject { FactoryGirl.build(:ec2_volume, instance_role: FactoryGirl.build(:instance_role), ec2_instance: FactoryGirl.build(:ec2_instance)) }

    it { is_expected.to be_invalid }
  end
end
