class Widget
  module ClassMethods
    def proxy_module
      @proxy_module ||= Widget::ProxyModule.new(self)
    end

    # call-seq:
    #   disable_subprocessing!
    #
    # Disables subprocessing for this widget.
    def disable_subprocessing!
      @subprocessing_disabled = true
    end

    # call-seq:
    #   enable_subprocessing!
    #
    # Enables subprocessing for this widget.
    def enable_subprocessing!
      @subprocessing_disabled = false
    end

    def subprocessing_enabled?
      !@subprocessing_disabled
    end

    def subprocessing_disabled?
      !!@subprocessing_disabled
    end

    # call-seq:
    #   shares :variable_name
    #   shares :variable_one, :variable_two
    #   shares :variable_one => :default_value, :variable_two => [:defaults]
    #
    # Declares shared variables to be used. When this proxy module is included by any class,
    # the class will have a number of accessors generated matching the names of these variables.
    # The including class will, in effect, have a series of instance variables created.
    #
    # This allows widgets to share variables between themselves, similarly to using class variables
    # except that each affected class can have entirely unique values for its shared variables.
    #
    def shares(*several_variants)
      proxy_module.shares(*several_variants)
      proxy_module.shared_variables.each do |name, value|
        if !instance_methods.include?(name)
          delegate name, "#{name}=", :to => :parent
        end
      end

      Widgets.imbue_all(proxy_module)
    end

    alias_method :shared, :shares
    alias_method :shared_variable, :shares

    # call-seq:
    #   entry_point :method_name
    #   entry_point :method_one, :method_two
    #
    # An entry point is a method which is delegated here from the parent object. The user of the
    # widget calls a method by the name of an entry point on the parent object, and that method
    # automatically initializes a new widget and then calls the method of the same name within the
    # widget.
    #
    # If a method exists in the widget but is not declared to be an entry point, external users
    # will have no way to call it. Conversely, if a method is declared to be an entry point but
    # the method does not exist, the user will get a NoMethodError. You must both define the method
    # and declare it as an entry point before it can be used properly. It does not matter what order
    # this is done in.
    #
    # Here is a simple example of adding a #go_home entry point to a navigational widget for a GPS object:
    #
    #  class GPS
    #    # ...
    #  end
    #
    #  class NavigationWidget < Widget
    #    affects :gps
    #    entry_point :go_home
    #
    #    def go_home
    #      parent.set_destination(home_coordinates)
    #    end
    #
    #    def home_coordinates
    #      [100, 100]
    #    end
    #  end
    #
    #  > gps = GPS.new
    #  > gps.go_home
    #  #=> GPS is going home!
    #
    #  > gps.home_coordinates
    #  #=> NoMethodError!
    #
    def entry_point(*method_names)
      method_names.each do |method_name|
        proxy_module.add_entry_point(method_name)
        entry_points << method_name.to_s
      end

      Widgets.imbue_all(proxy_module)
    end

    # An array of entry points. These are all Strings.
    def entry_points
      @entry_points ||= []
    end

    # call-seq:
    #   affects :class_name
    #   affects :ClassName
    #   affects :class_one, :class_two
    #
    # Lists one or more class names to be affected. These can be either underscored or CamelCased.
    #
    def affects(*class_names)
      class_names.each do |class_name|
#        raise Widgets::InvalidClassName, "Class name #{class_name.inspect} is not a symbol" unless class_name.kind_of?(Symbol)
        Widgets.mapping(class_name).affected_by(self)
      end
    end
  end
end
