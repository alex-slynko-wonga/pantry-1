require 'aws-sdk'
require 'singleton'

module Daemons
  class Config
    include Singleton
    def initialize
      read_config
      configure_aws
    end

    def config_for_fog
      @config['fog'].merge(provider: 'AWS')
    end

    def [](value)
      @config[value]
    end

    private
    def read_config
      env = ENV['environment'] || 'development'
      @config = YAML.load_file(File.join(File.dirname($0),"daemon.yml"))[env]
    end

    def configure_aws
      AWS.config(@config["aws"])
    end
  end

  def self.config
    Config.instance
  end
end

