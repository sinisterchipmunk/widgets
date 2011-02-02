module Widgets
  class Configuration
    # The paths which will be searched when loading widgets.
    # See #default_load_paths
    attr_accessor :load_paths

    # The default logger. If Rails is available, this defaults to Rails.logger.
    # Otherwise, defaults to an instance of Widgets::StderrLogger.
    attr_accessor :logger

    # If true, Widgets will send detailed output to #logger. Defaults to false.
    attr_writer :widget_logging_enabled

    def widget_logging_enabled?
      @widget_logging_enabled
    end

    def initialize
      @load_paths = default_load_paths
      @logger = defined?(Rails.logger) ? Rails.logger : Widgets::StderrLogger.new
      @widget_logging_enabled = false
    end

    # Returns each of the the #application_load_paths with "/widgets" appended.
    def default_load_paths
      application_load_paths.collect { |lp| File.join(lp, "widgets") }
    end

    # If ActiveSupport::Dependencies exists, then ActiveSupport's array of load paths will be returned.
    # Otherwise, $LOAD_PATH is returned.
    def application_load_paths
      if defined?(ActiveSupport::Dependencies)
        if ActiveSupport::Dependencies.respond_to?(:load_paths)
          ActiveSupport::Dependencies.load_paths
        else
          ActiveSupport::Dependencies.autoload_paths
        end
      else
        $LOAD_PATH
      end
    end
  end
end
