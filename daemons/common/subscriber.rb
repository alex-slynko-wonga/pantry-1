require_relative 'config'
require 'aws-sdk'

class Subscriber
  def initialize
    Daemons.config.configure_aws
  end

  def subscribe(queue_name, processor)
    AWS::SQS.new.queues.named(queue_name).poll do |msg|
      begin
        message = JSON.parse(msg.body)
        processor.handle_message(message)
      rescue JSON::ParserError
        false
      end
    end
  end
end
