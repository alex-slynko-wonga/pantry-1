require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

CONFIG = YAML.load(File.read(File.join(File.dirname(__FILE__), 'pantry.yml')))[Rails.env]

module Wonga
  module Pantry
    class Application < Rails::Application
      # Settings in config/environments/* take precedence over those specified here.
      # Application configuration should go into files in config/initializers
      # -- all .rb files in that directory are automatically loaded.

      # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
      # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
      # config.time_zone = 'Central Time (US & Canada)'

      # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
      # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
      # config.i18n.default_locale = :de

      # Do not swallow errors in after_commit/after_rollback callbacks.
      config.active_record.raise_in_transactional_callbacks = true

      ##### Additions
      config.action_mailer.default_url_options = { host: CONFIG['mailer']['host'] }
      config.action_mailer.default_options = CONFIG['mailer']['default_options'].symbolize_keys if CONFIG['mailer'] && CONFIG['mailer']['default_options']
      if CONFIG['pantry']['log']
        case CONFIG['pantry']['log']['logger']
        when 'syslog'
          require 'syslogger'
          facility = Syslog.const_get("LOG_#{CONFIG['pantry']['log']['log_facility'].upcase}")
          config.logger = Syslogger.new(CONFIG['pantry']['log']['app_name'], Syslog::LOG_PID | Syslog::LOG_CONS, facility)
        when 'file'
          if CONFIG['pantry']['log']['log_file']
            config.logger = CONFIG['pantry']['log']['log_file']
          end
        end
      end

      config.autoload_paths += %W(#{config.root}/lib)
    end
  end
end
