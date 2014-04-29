require 'spec_helper'

describe Admin::MaintenanceWindowsHelper do

  let(:some_admin) { FactoryGirl.create :superadmin }
  describe "#maintenance_window_active" do
    context "while a maintenance window is active" do
      let(:maint_window) { FactoryGirl.create(:admin_maintenance_window, user: some_admin, enabled: true)}
      it "returns true" do
        maint_window
        expect(helper.maintenance_window_active?).to eq true
      end
    end
    context "while no maintenance window is active" do
      let(:maint_window) { FactoryGirl.create(:admin_maintenance_window, user: some_admin, enabled: false)}
      it "returns false" do
        maint_window
        expect(helper.maintenance_window_active?).to eq false
      end
    end
  end

  describe "#get_active_maintenance_window" do
    let(:maint_window) { FactoryGirl.create(:admin_maintenance_window, user: some_admin, enabled: true)}
    it "returns first active maintenance window" do
      maint_window
      expect(helper.get_active_maintenance_window).to eq maint_window
    end
  end

end
