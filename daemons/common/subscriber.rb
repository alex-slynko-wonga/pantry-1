require_relative 'config'
require 'aws-sdk'

class Subscriber
  def subscribe(queue_name, processor)
    AWS::SQS.new.queues.named(queue_name).poll do |msg|
      begin
        message = JSON.parse(msg.body)
        processor.handle_message(message)
      rescue JSON::ParserError => e
        Publisher.new.publish_error("Malformed message #{message} from SQS with error: #{e}")
        false
      end
    end
  end
end
