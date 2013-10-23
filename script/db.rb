#!/usr/bin/env ruby

require 'mysql'
require 'aws-sdk'

AWS.config(
  region:             "eu-west-1",
  access_key_id:      "AKIEXAMPLEACCESSKEYZ",
  secret_access_key:  "your_secret_access_key"
)

ec2 = AWS::EC2.new

db_host = "localhost"
db_user = "root"
db_pass = ""
db_name = "pantry_development"

db = Mysql.new(
  db_host,
  db_user,
  db_pass,
  db_name
)

instance_ids = db.query "SELECT instance_id FROM ec2_instances"

id_ips = {}

instance_ids.each do |id|
  id.each do |id_inner|
    begin
      id_ips[id_inner] = ec2.instances[id_inner].private_ip_address; 
    rescue AWS::EC2::Errors::InvalidInstanceID::NotFound
      puts "Couldn't find instance with id: #{id_inner}"
    end      
  end
end

id_ips.each do |id, ip|
  update = db.prepare "UPDATE ec2_instances set ip_address = ? where instance_id = ?"
  update.execute ip, id
end

db.commit

db.close
