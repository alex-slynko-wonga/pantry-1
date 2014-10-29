module Admin::MaintenanceWindowsHelper
  def maintenance_window_active?
    Admin::MaintenanceWindow.active.exists?
  end

  def load_active_maintenance_window
    Admin::MaintenanceWindow.active.first
  end
end
