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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141009105311) do

  create_table "admin_maintenance_windows", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "message"
    t.datetime "start_at"
    t.datetime "end_at"
    t.boolean  "enabled"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "amis", force: true do |t|
    t.string   "name",       null: false
    t.string   "platform",   null: false
    t.string   "ami_id",     null: false
    t.boolean  "hidden"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ec2_instance_costs", force: true do |t|
    t.date     "bill_date"
    t.decimal  "cost",            precision: 10, scale: 2
    t.integer  "ec2_instance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "estimated"
  end

  add_index "ec2_instance_costs", ["bill_date", "ec2_instance_id"], name: "index_ec2_instance_costs_on_bill_date_and_ec2_instance_id", using: :btree

  create_table "ec2_instance_logs", force: true do |t|
    t.integer  "ec2_instance_id"
    t.string   "from_state"
    t.string   "event"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "updates"
  end

  create_table "ec2_instances", force: true do |t|
    t.string   "name"
    t.string   "instance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "team_id"
    t.integer  "user_id"
    t.string   "ami"
    t.string   "flavor"
    t.boolean  "bootstrapped"
    t.boolean  "joined"
    t.string   "subnet_id"
    t.string   "security_group_ids"
    t.string   "domain"
    t.string   "run_list"
    t.string   "platform"
    t.integer  "volume_size"
    t.boolean  "terminated"
    t.string   "ip_address"
    t.boolean  "dns"
    t.string   "state"
    t.boolean  "protected"
    t.integer  "environment_id"
  end

  create_table "environments", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "chef_environment"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "environment_type"
  end

  create_table "instance_roles", force: true do |t|
    t.string   "name",               null: false
    t.integer  "ami_id",             null: false
    t.string   "security_group_ids"
    t.string   "chef_role",          null: false
    t.string   "run_list"
    t.string   "instance_size",      null: false
    t.integer  "disk_size",          null: false
    t.boolean  "enabled",            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "instance_roles", ["ami_id"], name: "index_instance_roles_on_ami_id", using: :btree

  create_table "jenkins_servers", force: true do |t|
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ec2_instance_id"
  end

  add_index "jenkins_servers", ["team_id"], name: "index_jenkins_servers_on_team_id", using: :btree

  create_table "jenkins_slaves", force: true do |t|
    t.integer  "jenkins_server_id"
    t.integer  "ec2_instance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "removed",           default: false
  end

  add_index "jenkins_slaves", ["ec2_instance_id"], name: "index_jenkins_slaves_on_ec2_instance_id", using: :btree
  add_index "jenkins_slaves", ["jenkins_server_id"], name: "index_jenkins_slaves_on_jenkins_server_id", using: :btree

  create_table "team_members", force: true do |t|
    t.integer  "team_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "team_members", ["team_id", "user_id"], name: "index_team_members_on_team_id_and_user_id", unique: true, using: :btree

  create_table "teams", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "chef_environment"
    t.boolean  "disabled"
    t.string   "product"
    t.string   "region"
  end

  create_table "total_costs", force: true do |t|
    t.decimal  "cost",       precision: 10, scale: 2
    t.date     "bill_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "role"
  end

end
