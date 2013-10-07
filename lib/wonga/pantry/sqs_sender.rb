class Wonga::Pantry::SQSSender
  def initialize(queue_name)
    sqs = AWS::SQS.new
    url = sqs.queues.url_for(queue_name)
    @queue = sqs.queues[url]
  end

  def send_message(message)
    @queue.send_message(message.to_json)
  end
end
