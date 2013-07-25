#!/usr/bin/env ruby
require_relative '../common/subscriber'
require_relative '../common/config'
require_relative 'ec2_bootstrapped_event_handler'

config = Daemons.config
sqs_poller = Daemons::Subscriber.new()

case ARGV[0]
when "run"
  begin
    sqs_poller.subscribe(
      config['sqs']['queue_name'],
      Daemons::EC2BootstrappedEventHandler.new(config)
    )
  rescue => e
  	sleep(1)
    puts "#{e}"
    retry
  end
end
