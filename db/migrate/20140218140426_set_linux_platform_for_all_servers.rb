class SetLinuxPlatformForAllServers < ActiveRecord::Migration
  def change
    Ec2Instance.where(platform: '', run_list: 'role[jenkins_linux_server]').update_all(platform: 'linux')
  end
end
