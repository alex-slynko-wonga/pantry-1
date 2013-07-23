require 'singleton'
require 'aws-sdk'

module Daemons
  class Config
    include Singleton
    def initialize
      read_config
      AWS.config(@config["aws"])
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
      @config = YAML.load_file(File.join(File.dirname(__FILE__), "../daemon.yml"))[env]
    end
  end

  def self.config
    Config.instance
  end
end

Daemons.config
