class AddDisabledToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :disabled, :boolean
  end
end
