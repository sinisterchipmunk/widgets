require 'active_support/core_ext'

require File.join(File.dirname(__FILE__), "widgets/class_methods")
require File.join(File.dirname(__FILE__), "widgets/errors")

autoload :Widget, File.join(File.dirname(__FILE__), "widget")

module Widgets
  autoload :StderrLogger,  File.join(File.dirname(__FILE__), "widgets/stderr_logger")
  autoload :Configuration, File.join(File.dirname(__FILE__), "widgets/configuration")
  autoload :ProxySet,      File.join(File.dirname(__FILE__), "widgets/proxy_set")

  class << self
    # When included, Widgets makes some modifications to the underlying base class to enable widget support. These
    # modifications include:
    # * #process defined for processing and subprocessing. Note that this method is not defined if a method of the
    #   same name already exists; in that case, you'll need to specify one yourself. See
    #   Widgets::ClassMethods#process_with for details.
    def included(base)
      base.extend Widgets::ClassMethods
      base.process_with :process unless base.public_instance_methods.include?('process')
      base.send(:include, Widgets.mapping(base.name))
    end

    # Configure Widgets.
    # Ex:
    #  Widgets.configure do |config|
    #    config.logger = SyslogLogger.new('widgets')
    #  end
    #
    # See also Widgets::Configuration.
    def configure
      yield configuration
    end

    # Returns the Widgets configuration. See Widgets::Configuration.
    def configuration
      @configuration ||= Widgets::Configuration.new
    end

    # Returns the instance of ProxySet for the given key. The key is expected to correspond with a class name
    # as in the Widget::ClassMethods#affects method.
    def mapping(key)
      @mapping ||= {}
      @mapping[key] ||= Widgets::ProxySet.new
    end

    # Returns all proxy sets which include the specified proxy module.
    def proxy_sets(proxy_module)
      return [] unless @mapping
      @mapping.values.select { |value| value.include?(proxy_module) }
    end

    def reset_mapping
      @mapping.clear if @mapping
    end

    # Finds all instances of ProxySet in Widget#mapping which contain this proxy module, and calls #imbue on them.
    #
    # See: ProxySet#imbue
    #
    def imbue_all(proxy_module)
      proxy_sets(proxy_module).each { |set| set.imbue(proxy_module) }
    end
  end

  # Creates an instance of the specified widget that is associated with this object as if one of its entry points
  # were being called. This ignores whether or not the widget would normally affect the parent object.
  def instantiate_widget(klass)
    klass.new(self)
  end

  # Returns the singleton class of this object. Methods defined on a singleton class will not affect other
  # objects, even if they are both instances of the same class.
  def eigenclass
    class << self; self; end
  end
end
