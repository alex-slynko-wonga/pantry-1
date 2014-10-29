require 'spec_helper'

RSpec.describe TeamPolicy do
  let(:team) { FactoryGirl.build_stubbed(:team) }
  subject { described_class.new(user, team) }

  permission :update? do
    context 'for superadmin' do
      let(:user) { User.new(role: 'superadmin') }
      it { is_expected.to permit }
    end

    context 'for team member' do
      let(:user) { FactoryGirl.build(:user, team: team) }

      it { is_expected.to permit }
    end

    context 'for custom user' do
      let(:user) { User.new }

      it { is_expected.not_to permit }
    end

    context 'for inactive team' do
      let(:team) { FactoryGirl.build_stubbed(:team, disabled: true) }
      let(:user) { User.new(role: 'superadmin') }

      it { is_expected.not_to permit }
    end
  end

  permission :deactivate? do
    context 'for superadmin' do
      let(:user) { User.new(role: 'superadmin') }
      it { is_expected.to permit }
    end

    context 'for team member' do
      let(:user) { FactoryGirl.build(:user, team: team) }

      it { is_expected.not_to permit }
    end

    context 'for inactive team' do
      let(:team) { FactoryGirl.build_stubbed(:team, disabled: true) }
      let(:user) { User.new(role: 'superadmin') }

      it { is_expected.not_to permit }
    end
  end
end
