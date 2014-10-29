require 'spec_helper'

RSpec.describe Admin::MaintenanceWindowsHelper, type: :helper do

  describe '#maintenance_window_active' do
    context 'while a maintenance window is active' do
      let!(:maint_window) { FactoryGirl.create(:admin_maintenance_window, :enabled) }
      it 'returns true' do
        expect(helper.maintenance_window_active?).to eq true
      end
    end
    context 'while no maintenance window is active' do
      let!(:maint_window) { FactoryGirl.create(:admin_maintenance_window, :closed) }

      it 'returns false' do
        expect(helper.maintenance_window_active?).to eq false
      end
    end
  end

  describe '#load_active_maintenance_window' do
    let!(:maint_window) { FactoryGirl.create(:admin_maintenance_window, :enabled) }

    it 'returns first active maintenance window' do
      expect(helper.load_active_maintenance_window).to eq maint_window
    end
  end

end
