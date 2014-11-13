require 'spec_helper'

RSpec.describe Ec2InstancePolicy do
  subject { described_class.new(user, ec2_instance) }
  let(:state) { 'ready' }
  let(:ec2_instance) { FactoryGirl.build(:ec2_instance, state: state) }

  context 'for user of team' do
    let(:user) { FactoryGirl.build(:user, team: ec2_instance.team) }

    context 'when machine is ready' do
      it { is_expected.to permit(:destroy?) }
      it { is_expected.to permit(:shutdown_now?) }
      it { is_expected.to permit(:resize?) }
      it { is_expected.to_not permit(:start_instance?) }
      it { is_expected.to_not permit(:cleanup?) }
    end

    context 'when machine is loading' do
      let(:state) { 'booting' }

      it { is_expected.to_not permit(:destroy?) }
      it { is_expected.to_not permit(:shutdown_now?) }
      it { is_expected.to_not permit(:start_instance?) }
      it { is_expected.to_not permit(:resize?) }
      it { is_expected.to_not permit(:cleanup?) }
    end

    context 'when machine is shut down' do
      let(:state) { 'shutdown' }

      it { is_expected.to permit(:destroy?) }
      it { is_expected.to_not permit(:shutdown_now?) }
      it { is_expected.to permit(:resize?) }
      it { is_expected.to permit(:start_instance?) }
      it { is_expected.to_not permit(:cleanup?) }
    end

    it { is_expected.to permit(:create?) }

    context 'when site is in maintenance mode' do
      before(:each) do
        allow(subject).to receive(:maintenance_mode?).and_return(true)
      end

      it { is_expected.not_to permit(:create?) }
    end
  end

  context 'for machine owner' do
    let(:user) { FactoryGirl.build(:user, team: ec2_instance.team) }
    before(:each) do
      ec2_instance.user = user
    end

    context 'when machine is ready' do
      it { is_expected.to permit(:destroy?) }
      it { is_expected.to permit(:shutdown_now?) }
      it { is_expected.to permit(:resize?) }
      it { is_expected.to_not permit(:start_instance?) }
      it { is_expected.to_not permit(:cleanup?) }
    end

    context 'when machine is loading' do
      let(:state) { 'booting' }

      it { is_expected.to_not permit(:destroy?) }
      it { is_expected.to_not permit(:shutdown_now?) }
      it { is_expected.to_not permit(:start_instance?) }
      it { is_expected.to_not permit(:resize?) }
      it { is_expected.to permit(:cleanup?) }
    end

    context 'when machine is shut down' do
      let(:state) { 'shutdown' }

      it { is_expected.to permit(:destroy?) }
      it { is_expected.to_not permit(:shutdown_now?) }
      it { is_expected.to permit(:resize?) }
      it { is_expected.to permit(:start_instance?) }
      it { is_expected.to_not permit(:cleanup?) }
    end
  end

  context 'for superadmin' do
    let(:user) { User.new(role: 'superadmin') }

    context 'when machine is ready' do
      it { is_expected.to permit(:destroy?) }
      it { is_expected.to permit(:shutdown_now?) }
      it { is_expected.to permit(:resize?) }
      it { is_expected.to_not permit(:start_instance?) }
      it { is_expected.to_not permit(:cleanup?) }
    end

    context 'when machine is loading' do
      let(:state) { 'booting' }

      it { is_expected.to_not permit(:destroy?) }
      it { is_expected.to_not permit(:shutdown_now?) }
      it { is_expected.to_not permit(:resize?) }
      it { is_expected.to_not permit(:start_instance?) }
      it { is_expected.to permit(:cleanup?) }
    end

    context 'when machine is shut down' do
      let(:state) { 'shutdown' }

      it { is_expected.to permit(:destroy?) }
      it { is_expected.to_not permit(:shutdown_now?) }
      it { is_expected.to permit(:resize?) }
      it { is_expected.to permit(:start_instance?) }
      it { is_expected.to_not permit(:cleanup?) }
    end

    it { is_expected.to permit(:create?) }

    context 'when site is in maintenance mode' do
      before(:each) do
        allow(subject).to receive(:maintenance_mode?).and_return(true)
      end

      it { is_expected.to permit(:create?) }
    end
  end

  context 'for regular user' do
    let(:user) { User.new }

    it { is_expected.to_not permit(:destroy?) }
    it { is_expected.to_not permit(:shutdown_now?) }
    it { is_expected.to_not permit(:start_instance?) }
    it { is_expected.to_not permit(:resize?) }
    it { is_expected.to_not permit(:create?) }
    it { is_expected.to_not permit(:cleanup?) }

    context 'when team for instance is not set' do
      let(:ec2_instance) { Ec2Instance.new }

      it { is_expected.to permit(:create?) }
    end
  end
end
