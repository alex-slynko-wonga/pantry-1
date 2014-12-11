require 'spec_helper'

RSpec.describe JenkinsSlavePolicy do
  subject { described_class.new(user, JenkinsSlave.new(jenkins_server: jenkins_server)) }
  permissions :create? do
    context 'when jenkins server is ready' do
      let(:jenkins_server) { FactoryGirl.build(:jenkins_server, :running) }

      context 'for superadmin' do
        let(:user) { User.new(role: 'superadmin') }
        it { is_expected.to permit(:create?) }
      end

      context 'for user who is from team which created jenkins_server' do
        let(:user) { FactoryGirl.build(:user, team: jenkins_server.team) }
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

    context 'when jenkins server is just started' do
      let(:jenkins_server) { FactoryGirl.build(:jenkins_server, ec2_instance: FactoryGirl.build(:ec2_instance)) }
      let(:user) { User.new(role: 'superadmin') }

      it { is_expected.not_to permit(:create?) }
    end
  end
end
