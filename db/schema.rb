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

ActiveRecord::Schema.define(version: 20150210155626) do

  create_table "admin_maintenance_windows", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.string   "message",     limit: 255
    t.datetime "start_at"
    t.datetime "end_at"
    t.boolean  "enabled",     limit: 1
    t.integer  "user_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "amis", force: :cascade do |t|
    t.string   "name",               limit: 255, null: false
    t.string   "platform",           limit: 255, null: false
    t.string   "ami_id",             limit: 255, null: false
    t.boolean  "hidden",             limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "bootstrap_username", limit: 255
  end

  create_table "api_keys", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "key",         limit: 255
    t.text     "permissions", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ec2_instance_costs", force: :cascade do |t|
    t.date     "bill_date"
    t.decimal  "cost",                      precision: 10, scale: 2
    t.integer  "ec2_instance_id", limit: 4
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.boolean  "estimated",       limit: 1
  end

  add_index "ec2_instance_costs", ["bill_date", "ec2_instance_id"], name: "index_ec2_instance_costs_on_bill_date_and_ec2_instance_id", using: :btree

  create_table "ec2_instance_logs", force: :cascade do |t|
    t.integer  "ec2_instance_id", limit: 4
    t.string   "from_state",      limit: 255
    t.string   "event",           limit: 255
    t.integer  "user_id",         limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.text     "updates",         limit: 65535
  end

  create_table "ec2_instances", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.string   "instance_id",          limit: 255
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "team_id",              limit: 4
    t.integer  "user_id",              limit: 4
    t.string   "ami",                  limit: 255
    t.string   "flavor",               limit: 255
    t.boolean  "bootstrapped",         limit: 1
    t.boolean  "joined",               limit: 1
    t.string   "subnet_id",            limit: 255
    t.string   "security_group_ids",   limit: 255
    t.string   "domain",               limit: 255
    t.string   "run_list",             limit: 255
    t.string   "platform",             limit: 255
    t.integer  "volume_size",          limit: 4
    t.boolean  "terminated",           limit: 1
    t.string   "ip_address",           limit: 255
    t.boolean  "dns",                  limit: 1
    t.string   "state",                limit: 255
    t.boolean  "protected",            limit: 1
    t.integer  "environment_id",       limit: 4
    t.integer  "instance_role_id",     limit: 4
    t.string   "iam_instance_profile", limit: 255
  end

  add_index "ec2_instances", ["instance_role_id"], name: "index_ec2_instances_on_instance_role_id", using: :btree

  create_table "environments", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.string   "description",      limit: 255
    t.string   "chef_environment", limit: 255
    t.integer  "team_id",          limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "environment_type", limit: 255
    t.boolean  "hidden",           limit: 1
  end

  create_table "instance_roles", force: :cascade do |t|
    t.string   "name",                 limit: 255, null: false
    t.integer  "ami_id",               limit: 4,   null: false
    t.string   "security_group_ids",   limit: 255
    t.string   "chef_role",            limit: 255, null: false
    t.string   "run_list",             limit: 255
    t.string   "instance_size",        limit: 255, null: false
    t.integer  "disk_size",            limit: 4,   null: false
    t.boolean  "enabled",              limit: 1,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "iam_instance_profile", limit: 255
  end

  add_index "instance_roles", ["ami_id"], name: "index_instance_roles_on_ami_id", using: :btree

  create_table "jenkins_servers", force: :cascade do |t|
    t.integer  "team_id",         limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "ec2_instance_id", limit: 4
  end

  add_index "jenkins_servers", ["team_id"], name: "index_jenkins_servers_on_team_id", using: :btree

  create_table "jenkins_slaves", force: :cascade do |t|
    t.integer  "jenkins_server_id", limit: 4
    t.integer  "ec2_instance_id",   limit: 4
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.boolean  "removed",           limit: 1, default: false
  end

  add_index "jenkins_slaves", ["ec2_instance_id"], name: "index_jenkins_slaves_on_ec2_instance_id", using: :btree
  add_index "jenkins_slaves", ["jenkins_server_id"], name: "index_jenkins_slaves_on_jenkins_server_id", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,   null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "team_members", force: :cascade do |t|
    t.integer  "team_id",    limit: 4
    t.integer  "user_id",    limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "team_members", ["team_id", "user_id"], name: "index_team_members_on_team_id_and_user_id", unique: true, using: :btree

  create_table "teams", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.string   "description",      limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "chef_environment", limit: 255
    t.boolean  "disabled",         limit: 1
    t.string   "product",          limit: 255
    t.string   "region",           limit: 255
  end

  create_table "total_costs", force: :cascade do |t|
    t.decimal  "cost",       precision: 10, scale: 2
    t.date     "bill_date"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "username",     limit: 255
    t.string   "email",        limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "name",         limit: 255
    t.string   "role",         limit: 255
    t.datetime "last_seen_at"
  end

end
