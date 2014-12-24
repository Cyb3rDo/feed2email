module Feed2Email
  class Logger
    attr_reader :log_path, :log_level

    def initialize(log_path, log_level)
      @log_path = log_path
      @log_level = log_level
    end

    def log(severity, message)
      logger.add(::Logger.const_get(severity.upcase), message)
    end

    private

    def log_to
      if log_path.nil? || log_path == true
        $stdout
      elsif log_path # truthy but not true (a path)
        File.expand_path(log_path)
      end
    end

    def logger
      return @logger if @logger

      @logger = ::Logger.new(log_to)

      if log_level
        @logger.level = ::Logger.const_get(log_level.upcase)
      else
        @logger.level = ::Logger::INFO
      end

      @logger
    end
  end
end
