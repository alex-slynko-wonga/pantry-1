require 'spec_helper'

RSpec.describe Admin::MaintenanceWindow, type: :model do
  subject { FactoryGirl.build(:admin_maintenance_window) }

  it 'should be invalid without attributes (and not raise exception)' do
    expect(Admin::MaintenanceWindow.new).to be_invalid
  end

  context 'When enabling a Maintenance Window' do
    before(:each) do
      subject.enabled = true
    end

    it 'sets start_date to Time.current' do
      Time.freeze do
        subject.valid?
        expect(subject.start_at).to be Time.current
      end
    end

    context 'when another active Maintenance Window exists' do
      before(:each) do
        FactoryGirl.create(:admin_maintenance_window, :enabled)
      end

      it 'is invalid' do
        expect(subject).to be_invalid
      end
    end
    context 'when no other active Maintenance Window exists' do
      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    context 'when enabling a closed Maintenance Window' do
      subject { FactoryGirl.build(:admin_maintenance_window, :closed) }
      it 'is invalid' do
        expect(subject).to be_invalid
      end
    end
  end

end
