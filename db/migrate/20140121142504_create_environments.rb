class CreateEnvironments < ActiveRecord::Migration
  def up
    create_table :environments do |t|
      t.string :name
      t.string :description
      t.string :chef_environment
      t.integer :team_id

      t.timestamps
    end

    Ec2Instance.pluck(:chef_environment, :team_id).uniq.each do |environment, team_id|
      Environment.create(name: environment.tr('-', ' ').humanize, chef_environment: environment, team_id: team_id)
    end

    add_column :ec2_instances, :environment_id, :integer
    Ec2Instance.reset_column_information

    Ec2Instance.all.each do |instance|
      env = Environment.where(chef_environment: instance.chef_environment, team_id: instance.team_id).first
      instance.update_attributes(environment: env)
    end
  end

  def down
    remove_column :ec2_instances, :environment_id, :integer
    drop_table :environments
  end
end
