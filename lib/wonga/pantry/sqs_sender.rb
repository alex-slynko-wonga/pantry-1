class Wonga::Pantry::SQSSender
  def send_message(instance, queue_name = CONFIG["aws"]['queue_name'])
    sqs = AWS::SQS.new
    url = sqs.queues.url_for(queue_name)
    sqs.queues[url].send_message(instance.boot_message.to_json)
  end
end
