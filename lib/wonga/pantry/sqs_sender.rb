class Wonga::Pantry::SQSSender
  def send_message(msg, queue_name = "pantry_wonga_aws-ec2_boot_command")
    sqs = AWS::SQS.new
    url = sqs.queues.url_for(queue_name)
    sqs.queues[url].send_message(msg.to_json)
  end
end