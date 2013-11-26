class UpdateJenkinsServerProtection < ActiveRecord::Migration
  def up
    JenkinsServer.all.each do |i|
      i.ec2_instance.update_attributes(protected: true) 
    end
  end
end
