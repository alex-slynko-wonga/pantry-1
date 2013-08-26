require 'spec_helper'

describe JenkinsServer do
  describe "jenkins_slave" do
    it "avoids uninitialized constant JenkinsServer::JenkinsSlafe" do
      slave = FactoryGirl.build(:jenkins_slave)
      server = FactoryGirl.create(:jenkins_server)
      server.jenkins_slaves << slave
    end
  end

  describe "#instance_name" do
    let(:team) { FactoryGirl.build(:team, name: 'Test ,.!@£$%^&*() test for a long team name') }
    subject { FactoryGirl.build(:jenkins_server, team: team).instance_name }

    it "escapes team name" do
      expect(subject).to match(/\A(\w|-)*\z/)
    end

    it "is max 15 symbols" do
      expect(subject.size).to be 15
    end
  end
end
