require 'aws-sdk'
require 'yaml'
require 'json'
require 'timeout'
require 'rest_client'
require_relative '../common/config'
module Daemons
  class EC2BootstrappedEventHandler

    def initialize(config)
      @config = config
    end

    def handle_message(message)
      url = @config["pantry"]["url"]
      msg_json = JSON.parse(message["Message"])
      request_id = msg_json['request_id']
      request_url = "#{url}/aws/ec2_instances/#{request_id}"
      update = ({:bootstrapped => true}).to_json
      puts "#{update}"
      puts request_url
      Timeout::timeout(@config['pantry']['timeout']){
        RestClient.put(
          request_url, 
          update, 
          {
            :content_type => :json, 
            :'x-auth-token' => @config['pantry']['api_key']
          }
        )
      }
    end
  end
end

