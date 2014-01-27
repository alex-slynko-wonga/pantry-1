require 'spec_helper'

describe Team do
  subject { FactoryGirl.build(:team) }
  it { should be_valid }

  describe "without_jenkins" do
    it "finds team without jenkins server" do
      team = FactoryGirl.create(:team)
      FactoryGirl.create(:jenkins_server)
      expect(Team.count).to eq(2)
      expect(Team.without_jenkins.count).to eq(1)
    end

    it "finds team with terminated jenkins_server" do
      FactoryGirl.create(:jenkins_server, :terminated, team: subject)
      expect(Team.without_jenkins.count).to eq(1)
    end
  end

  it "creates an environment after creation" do
    team = FactoryGirl.build(:team)
    expect { team.save }.to change { Environment.count }.by(1)
  end

  it "creates a CI type enviroment after creation" do
    team = FactoryGirl.create(:team)
    expect( team.environments.first.environment_type ).to eq('CI')
  end
end
