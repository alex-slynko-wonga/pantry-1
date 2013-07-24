#!/usr/bin/env ruby
require 'rubygems'
require 'daemons'
require_relative '../common/subscriber'
require_relative '../common/config'
require_relative 'ec2_booted_event_handler'

config = Daemons::Config.new(File.join(File.dirname(__FILE__),"daemon.yml"))
puts config.inspect
daemon_config = {
  :backtrace => config['daemon']['backtrace'],
  :dir_mode => config['daemon']['dir_mode'].to_sym,
  :dir => "#{config['daemon']['dir']}",
  :monitor => config['daemon']['monitor']
}
#Daemons.run_proc(config['daemon']['app_name'], daemon_config) {
Daemons.run_proc(config['daemon']['app_name']) {
  begin
    Daemons::Subscriber.new.subscribe(config['sqs']['queue_name'],Daemons::EC2BootedEventHandler.new(config))
  rescue => e
    puts "#{e}"
    retry
  end
}
