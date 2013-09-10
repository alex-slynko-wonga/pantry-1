# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130910101409) do

  create_table "bills", :force => true do |t|
    t.date     "bill_date",                                                    :null => false
    t.decimal  "total_cost", :precision => 10, :scale => 2,                    :null => false
    t.boolean  "actual",                                    :default => false
    t.datetime "created_at",                                                   :null => false
    t.datetime "updated_at",                                                   :null => false
  end

  add_index "bills", ["bill_date"], :name => "index_bills_on_bill_date", :unique => true

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "ec2_instances", :force => true do |t|
    t.string   "name"
    t.string   "instance_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "team_id"
    t.integer  "user_id"
    t.string   "ami"
    t.string   "flavor"
    t.boolean  "booted"
    t.boolean  "bootstrapped"
    t.boolean  "joined"
    t.string   "subnet_id"
    t.string   "security_group_ids"
    t.string   "domain"
    t.string   "chef_environment"
    t.string   "run_list"
    t.string   "platform"
  end

  create_table "jenkins_servers", :force => true do |t|
    t.integer  "team_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "ec2_instance_id"
  end

  add_index "jenkins_servers", ["team_id"], :name => "index_jenkins_servers_on_team_id"

  create_table "jenkins_slaves", :force => true do |t|
    t.integer  "jenkins_server_id"
    t.integer  "ec2_instance_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "jenkins_slaves", ["ec2_instance_id"], :name => "index_jenkins_slaves_on_ec2_instance_id"
  add_index "jenkins_slaves", ["jenkins_server_id"], :name => "index_jenkins_slaves_on_jenkins_server_id"

  create_table "job_logs", :force => true do |t|
    t.integer  "job_id"
    t.text     "log_text"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "jobs", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "status"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "packages", :force => true do |t|
    t.string   "name"
    t.string   "version"
    t.string   "url"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "bag_title"
    t.string   "item_title"
    t.datetime "data_bag_updated_at"
  end

  create_table "team_members", :force => true do |t|
    t.integer  "team_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "team_members", ["team_id", "user_id"], :name => "index_team_members_on_team_id_and_user_id", :unique => true

  create_table "teams", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "chef_environment"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "name"
  end

end
