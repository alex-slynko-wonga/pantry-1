class AssignRolesToUsers < ActiveRecord::Migration
  def up
    pantry_team = Team.unscoped.where(name: 'Pantry Team').first || Team.unscoped.order(:id).first
    pantry_team.users.update_all(role: 'superadmin') if pantry_team
    User.where(role: nil).where(email: CONFIG['billing_users']).update_all(role: 'business_admin')
    User.where(role: nil).update_all(role: 'developer')
  end

  def down
    User.update_all(role: nil)
  end
end
