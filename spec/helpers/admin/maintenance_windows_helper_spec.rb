RSpec.describe Admin::MaintenanceWindowsHelper, type: :helper do
  describe '#active_maintenance_window' do
    it 'returns first active maintenance window' do
      maint_window = FactoryGirl.create(:admin_maintenance_window, :enabled)
      expect(helper.active_maintenance_window).to eq maint_window
    end

    it 'search for window only once per render' do
      expect(helper.active_maintenance_window).to be nil
      FactoryGirl.create(:admin_maintenance_window, :enabled)
      expect(helper.active_maintenance_window).to be nil
    end

    it "doesn't hide maintenance if it was disabled during render" do
      maint_window = FactoryGirl.create(:admin_maintenance_window, :enabled)
      expect(helper.active_maintenance_window).to be_present
      maint_window.update_attributes(enabled: false)
      expect(helper.active_maintenance_window).to be_present
    end
  end
end
