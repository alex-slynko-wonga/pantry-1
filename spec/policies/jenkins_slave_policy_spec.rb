require 'spec_helper'

describe JenkinsSlavePolicy do
  subject { described_class.new(user, JenkinsSlave.new(jenkins_server: jenkins_server)) }
  permissions :create? do

    context "when jenkins server is ready" do
      let(:jenkins_server) { FactoryGirl.build(:jenkins_server, :bootstrapped) }

      context "for superadmin" do
        let(:user) { User.new(role: 'superadmin') }
        it { should permit(:create?) }
      end

      context "for user who is from team which created jenkins_server" do
        let(:user) { FactoryGirl.build(:user, team: jenkins_server.team) }
        it { should permit(:create?) }
      end

      context "for custom user" do
        let(:user) { User.new }
        it { should_not permit(:create?) }
      end
    end

    context "when jenkins server is just started" do
      let(:jenkins_server) { FactoryGirl.build(:jenkins_server, ec2_instance: FactoryGirl.build(:ec2_instance)) }
      let(:user) { User.new(role: 'superadmin') }

      it { should_not permit(:create?) }
    end
  end
end


