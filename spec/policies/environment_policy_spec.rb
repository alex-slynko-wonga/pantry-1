require 'spec_helper'

describe EnvironmentPolicy do
  subject { described_class.new(user, environment) }
  let(:user) { User.new }
  let(:environment) { Environment.new(team: team) }
  let(:team) { Team.new }

  context "#permitted_types" do
    context "when team has CI environment" do
      before(:each) do
        team.build_ci_environment
      end

      it "should not include CI" do
        expect(subject.permitted_types).not_to include('CI')
      end
    end

    context "when team doesn't have CI environment" do
      it "should include CI" do
        expect(subject.permitted_types).to include('CI')
      end
    end

    context "when user is superadmin" do
      let(:user) { User.new(role: 'superadmin') }
      it "should include CUSTOM" do
        expect(subject.permitted_types).to include('CUSTOM')
      end
    end

    it "should not include CUSTOM" do
      expect(subject.permitted_types).not_to include('CUSTOM')
    end
  end
end
