require 'aws-sdk'
require 'singleton'

module Daemons
  class Config
    #include Singleton
    def initialize(config_file)
      read_config(config_file)
      configure_aws
    end

    def [](value)
      @config[value]
    end

    private
    def read_config(config_file)
      env = ENV['environment'] || 'development'
      @config = YAML.load_file(config_file)[env]
    end

    def configure_aws
      AWS.config(@config["aws"])
    end
  end

  #def self.config(config_file)
  #  Config.instance(config_file)
  #end
end

