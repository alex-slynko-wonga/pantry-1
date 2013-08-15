class CreateJenkinsServers < ActiveRecord::Migration
  def change
    create_table :jenkins_servers do |t|
      t.belongs_to :team

      t.timestamps
    end
    add_index :jenkins_servers, :team_id
  end
end
