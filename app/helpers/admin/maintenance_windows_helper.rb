module Admin::MaintenanceWindowsHelper
  def active_maintenance_window
    @active_maintenance_window = Admin::MaintenanceWindow.active.first unless instance_variable_defined? :@active_maintenance_window
    @active_maintenance_window
  end
end
