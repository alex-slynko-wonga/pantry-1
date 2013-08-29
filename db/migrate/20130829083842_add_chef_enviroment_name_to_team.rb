class AddChefEnviromentNameToTeam < ActiveRecord::Migration
  def change
    add_column :teams, :chef_environment, :string
    Team.reset_column_information
    Team.all.each do |team|
      team.update_attribute(:chef_environment, Wonga::Pantry::ChefEnvironmentBuilder.new(team).chef_environment)
    end
  end
end
