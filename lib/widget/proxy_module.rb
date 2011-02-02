class Widget
  # Every widget has a proxy module. Proxy modules are internal instances of Module containing methods which will
  # eventually be delegated to the classes the widget affects. The widget's entry point methods are added to the
  # proxy module and the proxy module itself is added to the affected class when the class includes the +Widgets+
  # module. This allows the proxy methods to be defined before the affected class is defined, and also removes the
  # need for the affected class to directly mix in the desired proxies. (This is a good thing, because the affected
  # class usually won't _know_ which modules to mix in.)
  #
  # ProxyModule also handles some internal meta data such as shared variables which will be added to the affected class
  # after the module has been included into it.
  #
  # ProxyModule is handled internally and should rarely or never have to be interfaced with directly. You can get
  # the proxy module for a specific Widget class by calling Klass::proxy_module.
  #
  # Ex:
  #   class MyWidget < Widget
  #     # ...
  #   end
  #
  #   MyWidget.proxy_module
  #   #=> Widget::ProxyModule
  class ProxyModule < Module
    # See: Widget::ClassMethods#shares
    def shares(*several_variants)
      several_variants.each do |var|
        if var.kind_of?(Hash)
          shared_variables.merge! var
        elsif !shared_variables.key?(var)
          shared_variables.merge!({ var => nil })
        end
      end
    end

    module SharedVariables #:nodoc:
      def add_shared_variable(variable_name, default_value)
        shared_variables[variable_name] = default_value if shared_variables[variable_name].nil?
        attr_accessor variable_name
      end

      def shared_variables
        @shared_variables ||= {}
      end
    end

    def included(base) #:nodoc;
      base.send(:extend, ProxyModule::SharedVariables)

      shared_variables.each do |variable_name, default_value|
        base.send :add_shared_variable, variable_name, default_value
      end

      base.send(:define_method, :setup_shared_variables) do
        self.class.shared_variables.each do |variable_name, default_value|
          instance_variable_set("@#{variable_name}", (default_value.dup rescue default_value))
        end
      end

      base.class_eval do
        alias initialize_without_proxies initialize
        def initialize(*args, &block)
          setup_shared_variables
          initialize_without_proxies(*args, &block)
        end
      end
    end

    # An array of shared variable descriptors. Each descriptor is an instance of Hash.
    def shared_variables
      @shared_variables ||= {}
    end
  end
end
