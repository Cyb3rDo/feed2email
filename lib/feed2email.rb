module Feed2Email
  CONFIG_DIR = File.expand_path('~/.feed2email')

  def self.config
    @config ||= Config.new(File.join(CONFIG_DIR, 'config.yml'))
  end

  def self.logger
    @logger ||= Logger.new(config['log_path'], config['log_level'])
  end

  def self.log(*args)
    logger.log(*args) # delegate
  end
end

require 'feed2email/config'
require 'feed2email/logger'
