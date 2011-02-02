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
  #
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

    def initialize(widget_class) #:nodoc:
      @widget_class = widget_class
      super()
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

    def included(base) #:nodoc:
      # note: base is always a ProxySet

      # Add shared variables to the proxy set
      shared_variables.each do |variable_name, default_value|
        base.class_eval do
          define_method(variable_name) { instance_variable_set("@#{variable_name}",
                                         instance_variable_get("@#{variable_name}") || default_value) }
          define_method("#{variable_name}=") { |value| instance_variable_set("@#{variable_name}", value) }
        end
      end

      # Add entry points to the proxy set
      entry_points.each do |entry_point|
        base.add_entry_point(entry_point, @widget_class)
      end
    end

    # An array of shared variable descriptors. Each descriptor is an instance of Hash.
    def shared_variables
      @shared_variables ||= {}
    end

    # Adds the specified entry point to the proxy set. The entry point will lead into an instance of the specified
    # subclass of Widget. If the entry point name conflicts with any other entry point names, an error will be raised.
    def add_entry_point(entry_point)
      entry_point = entry_point.to_sym unless entry_point.kind_of?(Symbol)
      entry_points << entry_point unless entry_points.include?(entry_point)
    end

    def entry_points
      @entry_points ||= []
    end
  end
end
