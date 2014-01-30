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
    let(:team) { Team.new }

    it "gets instance_name from the chef environment" do
      expect(subject.instance_name).to eq(team.ci_environment.chef_environment)
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

  context "when team already have a jenkins server" do
    let!(:existing_server) { FactoryGirl.create(:jenkins_server, team: team) }

    it { should be_invalid }

    context "which is terminated" do
      before(:each) do
        existing_server.ec2_instance.update_attribute(:state, :terminated)
      end

      it { should be_valid }

      it "filters terminated instances" do
        expect(JenkinsServer.count).to be_zero
        expect(JenkinsServer.unscoped.count).to_not be_zero
      end
    end
  end
end
