require 'spec_helper'

describe Environment do
  subject { FactoryGirl.build(:environment) }

  context "when team does not have CI environment" do
    let(:team) { FactoryGirl.create(:team) }
    it "allows to create new CI environment" do
      expect(FactoryGirl.build(:environment, team: team, environment_type: 'CI')).to be_valid
    end
  end

  context "when team has CI environment" do
    let(:team) { FactoryGirl.create(:team, :with_ci_environment) }
    it "does not allow to create new CI environment" do
      expect(FactoryGirl.build(:environment, team: team, environment_type: 'CI')).to be_invalid
      expect(team.ci_environment).to be_valid
    end
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
