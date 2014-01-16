require 'spec_helper'

describe JenkinsServer do
  let(:team) { FactoryGirl.build(:team) }
  subject { FactoryGirl.build(:jenkins_server, team: team) }

  describe "jenkins_slave" do
    it "avoids uninitialized constant JenkinsServer::JenkinsSlave" do
      slave = JenkinsSlave.new
      subject.jenkins_slaves << slave
      expect(subject.jenkins_slaves.size).to eq(1)
    end
  end

  describe "#instance_name" do
    let(:team) { Team.new(chef_environment: 'test') }

    it "gets instance_name from team" do
      expect(subject.instance_name).to eq('test')
    end
  end

  describe "jenkins_slaves" do
    it "shows only not removed slaves" do
      slave = FactoryGirl.create(:jenkins_slave)
      server = slave.jenkins_server
      slave.update_attribute(:removed, true)
      expect(server.jenkins_slaves).to be_blank
    end
  end

  it { should be_valid }

  it "is invalid when team already have a jenkins server" do
    FactoryGirl.create(:jenkins_server, team: team)
    expect(subject).to be_invalid
  end

  it "is valid when team's Jenkins server is terminated" do
    FactoryGirl.create(:jenkins_server, team: team, ec2_instance: FactoryGirl.build(:ec2_instance, :terminated, team: team))
    expect(subject).to be_valid
  end

  it "filters terminated instances" do
    FactoryGirl.create(:jenkins_server, team: team, ec2_instance: FactoryGirl.build(:ec2_instance, :terminated, team: team))
    expect(JenkinsServer.count).to be_zero
    expect(JenkinsServer.unscoped.count).to_not be_zero
  end
end
