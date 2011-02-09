require 'active_support/core_ext'
require 'active_support/dependencies'

require File.join(File.dirname(__FILE__), "widgets/class_methods")
require File.join(File.dirname(__FILE__), "widgets/errors")

# load the Railtie if Rails is around.
begin
  require 'rails'
  require File.join(File.dirname(__FILE__), "widgets/railtie")
rescue LoadError
  # fail silently if Rails isn't around, because we won't miss it
end

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
      force(base.name, base)
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

    # Returns all Widgets which affect the specified class name.
    def affecting(key)
      mapping(key).widgets
    end

    # Forcibly includes the proxy set for the specified key into the specified base. This completely
    # ignores whether or not the widgets within the specified set were actually _designed_ for the
    # base class. Use with care.
    def force(key, base)
      base.send(:include, mapping(key))
    end

    # Returns the instance of ProxySet for the given key. The key is expected to correspond with a class name
    # as in the Widget::ClassMethods#affects method.
    def mapping(key)
      @mapping ||= {}
      @mapping[normalize_mapping_key(key)] ||= Widgets::ProxySet.new
    end

    # Returns the given key, converted to a String and then CameLized to resemble a Ruby class name.
    def normalize_mapping_key(key)
      key = key.to_s unless key.kind_of?(String)
      key.camelize
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

    # Kicks off the widget autoload process. See also Widget::Configuration.
    def load!
      configuration.load_paths.each do |load_path|
        Dir[File.join(load_path, "**/*.rb")].each do |path|
          ActiveSupport::Dependencies.require_or_load path
        end
      end
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
