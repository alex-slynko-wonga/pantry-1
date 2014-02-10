require 'spec_helper'

describe Ec2InstancePolicy do
  subject { described_class.new(user, ec2_instance) }
  let(:state) { 'ready' }
  let(:ec2_instance) { FactoryGirl.build(:ec2_instance, state: state) }

  context "for user of team" do
    let(:user) { FactoryGirl.build(:user, team: ec2_instance.team) }

    context "when machine is ready" do
      it { should permit(:destroy?) }
      it { should permit(:shutdown_now?) }
      it { should permit(:resize?) }
      it { should_not permit(:start_instance?) }
    end

    context "when machine is loading" do
      let(:state) { 'booting' }

      it { should_not permit(:destroy?) }
      it { should_not permit(:shutdown_now?) }
      it { should_not permit(:start_instance?) }
      it { should_not permit(:resize?) }
    end

    context "when machine is shut down" do
      let(:state) { 'shutdown' }

      it { should permit(:destroy?) }
      it { should_not permit(:shutdown_now?) }
      it { should permit(:resize?) }
      it { should permit(:start_instance?) }
    end
  end

  context "for superadmin" do
    let(:user) { User.new(role: 'superadmin') }

    context "when machine is ready" do
      it { should permit(:destroy?) }
      it { should permit(:shutdown_now?) }
      it { should permit(:resize?) }
      it { should_not permit(:start_instance?) }
    end

    context "when machine is loading" do
      let(:state) { 'booting' }

      it { should_not permit(:destroy?) }
      it { should_not permit(:shutdown_now?) }
      it { should_not permit(:resize?) }
      it { should_not permit(:start_instance?) }
    end

    context "when machine is shut down" do
      let(:state) { 'shutdown' }

      it { should permit(:destroy?) }
      it { should_not permit(:shutdown_now?) }
      it { should permit(:resize?) }
      it { should permit(:start_instance?) }
    end
  end

  context "for regular user" do
    let(:user) { User.new }

    it { should_not permit(:destroy?) }
    it { should_not permit(:shutdown_now?) }
    it { should_not permit(:start_instance?) }
    it { should_not permit(:resize?) }
  end
end

