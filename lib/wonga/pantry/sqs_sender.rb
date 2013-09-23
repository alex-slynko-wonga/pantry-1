class Wonga::Pantry::SQSSender
  def send_message(message, queue_name = CONFIG["aws"]['queue_name'])
    sqs = AWS::SQS.new
    url = sqs.queues.url_for(queue_name)
    sqs.queues[url].send_message(message.to_json)
  end
end
