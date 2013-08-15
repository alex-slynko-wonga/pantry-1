class CreateJenkinsServers < ActiveRecord::Migration
  def change
    create_table :jenkins_servers do |t|
      t.belongs_to :Team

      t.timestamps
    end
    add_index :jenkins_servers, :Team_id
  end
end
