RSpec.describe 'aws/ec2_instances/new.html.haml', type: :view do
  let(:ec2_instance) { Ec2Instance.new }
  let(:instance_roles) { FactoryGirl.build_stubbed_list(:instance_role, 1) }
  let(:policy_double) { instance_double(Ec2InstancePolicy, custom_ami?: false, custom_volume?: false) }
  let(:team) { FactoryGirl.build_stubbed(:team) }
  let(:user) { FactoryGirl.build_stubbed(:user, team: team) }
  let(:ec2_adapter) do
    instance_double(Wonga::Pantry::Ec2Adapter, amis: [['windows', ['ami-123']]], flavors: { 'flavor' => '80' }, subnets: ['subnet'], security_groups: ['group'])
  end

  before(:each) do
    assign(:ec2_instance, ec2_instance)
    allow(RSpec::Mocks.configuration).to receive(:verify_partial_doubles?) # FIXME: load helpers into view
    allow(view).to receive(:policy).and_return(policy_double)
    assign(:ec2_adapter, ec2_adapter)
    assign(:instance_roles, instance_roles)
    allow(view).to receive(:policy).and_return(instance_double(Ec2InstancePolicy, custom_ami?: false, custom_iam?: false))
  end

  context 'when team exists' do
    let(:environments) { ['environment.name'] }

    before(:each) do
      assign(:environments, environments)
      assign(:team, team)
      assign(:team_name, team.name)
    end

    it 'fill environments for specific team' do
      render
      expect(response).to include('environment.name')
      expect(response).to include('Team: ' + team.name)
    end
  end

  context 'when team is empty' do
    let(:grouped_environments) { { 'Pantry' => [%w(environment_name 2)] } }

    before(:each) do
      assign(:grouped_environments, grouped_environments)
    end

    it 'fill all environments' do
      render
      expect(response).to include('Pantry')
      expect(response).to include('environment_name')
    end
  end
end
