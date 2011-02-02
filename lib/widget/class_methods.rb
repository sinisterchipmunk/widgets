class Widget
  module ClassMethods
    def proxy_module
      @proxy_module ||= Widget::ProxyModule.new
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
    #   affects :class_name
    #   affects :ClassName
    #   affects :class_one, :class_two
    #
    # Lists one or more class names to be affected. These can be either underscored or CamelCased.
    #
    def affects(*class_names)
      class_names.each do |class_name|
#        raise Widgets::InvalidClassName, "Class name #{class_name.inspect} is not a symbol" unless class_name.kind_of?(Symbol)
        class_name = class_name.to_s unless class_name.kind_of?(String)
        class_name = class_name.camelize
        Widgets.mapping(class_name).imbue(proxy_module)
      end
    end
  end
end
