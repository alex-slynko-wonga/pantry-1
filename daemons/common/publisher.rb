require_relative 'config'

class Publisher
  def publish(topic, message)
    sns = AWS::SNS.new
    sns.topics[topic].publish message.to_json
  end

  def publish_error(error_text)
    sns = AWS::SNS.new
    sns.topics[Daemons.config['sns']['error_arn']].publish error_text
  end
end

