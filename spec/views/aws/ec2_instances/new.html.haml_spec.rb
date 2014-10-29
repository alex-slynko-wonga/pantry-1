require 'spec_helper'

RSpec.describe 'aws/ec2_instances/new.html.haml', type: :view do
  let(:ec2_instance) { Ec2Instance.new }
  let(:team) { FactoryGirl.build_stubbed(:team) }
  let(:user) { FactoryGirl.build_stubbed(:user, team: team) }
  let(:environment) { FactoryGirl.build_stubbed(:environment) }
  let(:environments) { [environment.name] }
  let(:instance_role) { FactoryGirl.build_stubbed(:instance_role) }
  let(:instance_roles) { [instance_role] }
  let(:grouped_environments) { { 'Pantry' => [[environment.name, '2']] } }
  let(:ec2_adapter) do
    instance_double(Wonga::Pantry::Ec2Adapter,
                    amis: [['windows', ['ami-123']]],
                    flavors: { 'flavor' => '80' },
                    subnets: ['subnet'],
                    security_groups: ['group'])
  end

  before(:each) do
    assign(:ec2_instance, ec2_instance)
    allow(RSpec::Mocks.configuration).to receive(:verify_partial_doubles?) # FIXME: load helpers into view
    allow(view).to receive(:current_user).and_return(user)
    assign(:ec2_adapter, ec2_adapter)
    assign(:environments, environments)
    assign(:instance_roles, instance_roles)
    assign(:grouped_environments, grouped_environments)
    expect(view).to receive(:policy).and_return(instance_double(Ec2InstancePolicy, custom_ami?: false))
  end

  context 'when team exists' do
    it 'fill environments for specific team' do
      assign(:team, team)
      assign(:team_name, team.name)
      render
      expect(response).to include(environments.first)
      expect(response).to include('Team: ' + team.name)
    end
  end

  context 'when team is empty' do
    it 'fill all environments' do
      render
      expect(response).to include(grouped_environments.first[0])
      expect(response).to include(environments.first)
    end
  end
end
