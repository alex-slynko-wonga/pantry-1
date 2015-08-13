require 'spec_helper'

RSpec.describe ApplicationPolicy do
  context '#as_json' do
    class JsonPolicy < ApplicationPolicy
      def initialize(allow)
        @allow = allow
      end

      def test
        @allow
      end

      def testy?
        @allow
      end
    end

    subject { JsonPolicy.new(true) }

    it 'generates hash with method names as keys' do
      expect(subject.as_json).to be_a(Hash)
    end

    it 'gets only methods with question mark at the end' do
      expect(subject.as_json[:testy]).to be_truthy
      expect(subject.as_json).not_to have_key(:test)
    end

    context 'when method returns false' do
      subject { JsonPolicy.new(false) }

      it 'skipped' do
        expect(subject.as_json).to be_blank
      end
    end
  end

  context '#maintenance_mode?' do
    subject { described_class.new(window, nil) }

    context 'when there is active maintenance window' do
      let(:window) { FactoryGirl.create(:admin_maintenance_window, :enabled) }

      it { is_expected.to be_maintenance_mode }
    end

    context 'when maintenance window is disabled' do
      let(:window) { FactoryGirl.create(:admin_maintenance_window, :closed) }

      it { is_expected.not_to be_maintenance_mode }
    end
  end
end
