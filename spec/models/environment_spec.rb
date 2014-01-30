require 'spec_helper'

describe Environment do
  subject { FactoryGirl.build(:environment) }
  let(:team) { FactoryGirl.create(:team) }

  it { should be_valid }

  it "allows only one CI environment_type per team" do
    expect(FactoryGirl.build(:environment, team: team, environment_type: 'CI')).to be_invalid
    team.ci_environment.chef_environment = 'chef_env'
    expect(team.ci_environment).to be_valid
  end

  context ".available" do
    it "filters environment without chef_environment field" do
      team = FactoryGirl.create(:team)
      user = FactoryGirl.build(:user, team: team)
      FactoryGirl.create(:environment, chef_environment: nil, team: team)
      FactoryGirl.create(:environment, chef_environment: 'some', team: team)
      expect(Environment.available(user).count).to eq(1)
    end

    it "filters environment from other teams" do
      team = FactoryGirl.create(:team)
      user = FactoryGirl.build(:user, team: team)
      FactoryGirl.create(:environment, chef_environment: 'some', team: team)
      FactoryGirl.create(:environment, chef_environment: 'some')
      expect(Environment.available(user).count).to eq(1)
    end
  end
end
