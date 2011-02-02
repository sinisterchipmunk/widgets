module Widgets
  class ProxySet < Module
    # Works around a limitation of Ruby by searching ObjectSpace for any class which has already included this
    # instance of ProxySet, and then reincludes this instance of ProxySet. This has the effect of "refreshing"
    # certain methods, which may be missing.
    #
    # A more detailed explanation follows.
    #
    # Often, when the widgets are being initialized, the process follows a similar order to:
    #   - Class includes Module1
    #   - Module1 includes Module2
    #   - Class is now expected to include methods from Module2, but it doesn't, because its references haven't
    #     been updated.
    #
    # Class must explicitly reinclude Module1 in order to include methods from Module2. Unfortunately, by this time,
    # we have already forgotten what class included Module1 to begin with. So, this method will hunt down the forgotten
    # class(es) for us, and reinclude itself into them, thus keeping the proxies for each class up-to-date.
    #
    def imbue(proxy_module)
      include proxy_module
      ObjectSpace.each_object(Class) do |klass|
        klass.send :include, self if klass.include? self
      end
    end

    # Adds the specified entry point to the proxy set. The entry point will lead into an instance of the specified
    # subclass of Widget. If the entry point name conflicts with any other entry point names, an error will be raised.
    def add_entry_point(entry_point, widget_class)
      entry_points[entry_point] = widget_class
      class_eval <<-end_code, __FILE__, __LINE__+1
        def #{entry_point}(*args, &block); enter_widget(:#{entry_point}, *args, &block); end
      end_code
    end

    def entry_points
      @entry_points ||= {}
    end

    def included(base)
      base.class_eval do
        def self.widget_entry_points
          hash = (@widget_entry_points ||= {})
          hash.merge! super if superclass.instance_methods.include?('widget_entry_points')
          hash
        end

        def widget_entry_points; self.class.widget_entry_points; end

        def enter_widget(entry_point, *args, &block)
          widget = instantiate_widget(widget_entry_points[entry_point])
          widget.send(entry_point, *args, &block)
        rescue ArgumentError => ae
          if ae.backtrace[0] =~ /#{Regexp::escape entry_point}/
            raise ArgumentError, ae.message, caller
          else
            raise ae
          end
        end
      end

      base.widget_entry_points.merge! entry_points
    end
  end
end
