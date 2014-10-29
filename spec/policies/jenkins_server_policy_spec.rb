require 'spec_helper'

RSpec.describe JenkinsServerPolicy do
  let(:team) { Team.new }
  subject { described_class.new(user, JenkinsServer.new(team: team)) }
  permissions :create? do

    let(:jenkins_server) { FactoryGirl.build(:jenkins_server, :running) }

    context 'for superadmin' do
      let(:user) { User.new(role: 'superadmin') }
      it { is_expected.to permit(:create?) }
    end

    context 'for team member' do
      let(:user) { FactoryGirl.build(:user, team: team) }
      it { is_expected.to permit(:create?) }

      context 'when site in active maintenance mode' do
        before(:each) do
          FactoryGirl.create(:admin_maintenance_window, :enabled)
        end

        it { is_expected.not_to permit(:create?) }
      end
    end

    context 'for custom user' do
      let(:user) { User.new }
      it { is_expected.not_to permit(:create?) }
    end
  end
end
