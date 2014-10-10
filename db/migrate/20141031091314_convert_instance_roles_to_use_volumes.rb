class ConvertInstanceRolesToUseVolumes < ActiveRecord::Migration
  def up
    adapter = Wonga::Pantry::Ec2Adapter.new User.first
    InstanceRole.all.each do |role|
      role.ec2_volumes = adapter.generate_volumes(role.ami.ami_id, role.disk_size)
      role.save!
    end
  end

  def down
    InstanceRole.all.each { |role| role.ec2_volumes.delete_all }
  end
end
