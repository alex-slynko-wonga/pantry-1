require_relative 'config'

class Publisher
  def initialize
    Daemons.config.configure_aws
  end

  def publish(topic, message)
    sns = AWS::SNS.new
    sns.topics[topic].publish message.to_json
  end
end

