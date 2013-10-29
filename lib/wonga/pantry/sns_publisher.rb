class Wonga::Pantry::SNSPublisher
  def initialize(topic_arn)
    sns = AWS::SNS.new
    @topic = sns.topics[topic_arn]
  end

  def publish_message(message)
    @topic.publish(message.to_json)
  end
end
