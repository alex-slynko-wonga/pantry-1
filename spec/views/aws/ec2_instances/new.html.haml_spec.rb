require 'spec_helper'

describe 'aws/ec2_instances/new.html.haml' do
  let(:ec2_instance) { Ec2Instance.new }
  let(:user) { FactoryGirl.build_stubbed(:user, team: FactoryGirl.build_stubbed(:team)) }
  let(:environment) { FactoryGirl.build_stubbed(:environment) }
  let(:ec2_adapter) { instance_double(Wonga::Pantry::Ec2Adapter, amis: [['windows', ['ami-123']]], flavors: ['flavor'], subnets: ['subnet'], security_groups: ['group']) }

  before(:each) do
    assign(:ec2_instance, ec2_instance)
    allow(view).to receive(:current_user).and_return(user)
    expect(Environment).to receive(:available).and_return([environment])
    assign(:ec2_adapter, ec2_adapter)
    expect(view).to receive(:policy).and_return(instance_double(Ec2InstancePolicy, custom_ami?: false))
  end

  it "shows only allowed enviroments" do
    render
    expect(response).to include(environment.name)
  end
end
