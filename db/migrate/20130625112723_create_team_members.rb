class CreateTeamMembers < ActiveRecord::Migration
  def change
    create_table :team_members do |t|
      t.references :team
      t.references :user

      t.timestamps
    end
    add_index :team_members, [:team_id, :user_id], unique: true
  end
end
