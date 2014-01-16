require 'spec_helper'

describe TeamPolicy do
  let(:team) { FactoryGirl.build_stubbed(:team) }
  permission :update? do
    subject { described_class.new(user, team) }
    context "for superadmin" do
      let(:user) { User.new(role: 'superadmin') }
      it { should permit }
    end

    context "for team member" do
      let(:user) { FactoryGirl.build(:user, team: team) }

      it { should permit }
    end

    context "for custom user" do
      let(:user) { User.new }

      it { should_not permit }
    end
  end
end
