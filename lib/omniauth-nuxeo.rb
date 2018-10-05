require 'omniauth/nuxeo'

# Define the logger so that it can attach to the Rails logger or be defined by consumer
module OmniauthNuxeo

  def self.logger
    @@logger ||= defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
  end

  def self.logger=(logger)
    @@logger = logger
  end

end