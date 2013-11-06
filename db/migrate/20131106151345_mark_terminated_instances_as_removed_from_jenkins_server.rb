class MarkTerminatedInstancesAsRemovedFromJenkinsServer < ActiveRecord::Migration
  def up
    ids = JenkinsSlave.joins(:ec2_instance).where(ec2_instances: { terminated: true}).pluck(:id)
    JenkinsSlave.where(id: ids).update_all(removed: true)
  end
end
