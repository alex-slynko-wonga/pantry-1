RSpec.describe InstanceRole do
  context '#full_run_list' do
    subject { FactoryGirl.build(:instance_role, chef_role: chef_role, run_list: run_list).full_run_list }

    let(:chef_role) { 'test' }
    let(:run_list) { 'recipe[some]' }

    it 'joins role and run_list' do
      is_expected.to include("role[#{chef_role}]")
      is_expected.to include(run_list)
      is_expected.to include(',')
    end

    context 'when run_list is empty' do
      let(:run_list) { '' }

      it 'returns role' do
        is_expected.to eq 'role[test]'
      end
    end
  end
end
