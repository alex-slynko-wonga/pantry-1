class LinkEnvironmentToJenkins < ActiveRecord::Migration
  def up
    JenkinsServer.all.each {|j| j.ec2_instance.environment.update_attributes(environment_type: 'CI')}
  end

  def down
    JenkinsServer.all.each {|j| j.ec2_instance.environment.update_attributes(environment_type: nil)}
  end
end
