require 'spec_helper'

describe JenkinsServerPolicy do
  let(:team) { Team.new }
  subject { described_class.new(user, JenkinsServer.new(team: team)) }
  permissions :create? do

    let(:jenkins_server) { FactoryGirl.build(:jenkins_server, :running) }

    context "for superadmin" do
      let(:user) { User.new(role: 'superadmin') }
      it { should permit(:create?) }
    end

    context "for team member" do
      let(:user) { FactoryGirl.build(:user, team: team) }
      it { should permit(:create?) }

      context "when site in active maintenance mode" do
        before(:each) do
          FactoryGirl.create(:admin_maintenance_window, :enabled)
        end

        it { should_not permit(:create?) }
      end
    end

    context "for custom user" do
      let(:user) { User.new }
      it { should_not permit(:create?) }
    end
  end
end


