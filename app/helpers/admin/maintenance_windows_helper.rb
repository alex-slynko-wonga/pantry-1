module Admin::MaintenanceWindowsHelper

  def maintenance_window_active?
    Admin::MaintenanceWindow.active.exists?
  end

  def get_active_maintenance_window
    Admin::MaintenanceWindow.active.first
  end

end
