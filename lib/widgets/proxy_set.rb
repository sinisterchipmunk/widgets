module Widgets
  class ProxySet < Module
    # An array containing the classes of all widgets which provide proxies into this set.
    def widgets
      @widgets ||= []
    end

    # Adds the widget's proxy methods to this proxy set.
    def affected_by(widget)
      widgets << widget unless widgets.include?(widget)
      imbue(widget.proxy_module)
    end

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
      # TODO Refactor all of this garbage.

      proxy_set = self
      def base.widget_proxy_set
        @widget_proxy_set
      end

      base.instance_variable_set("@widget_proxy_set", proxy_set)

      base.class_eval do
        def widget_entry_points
          points = {}
          parent = self.class
          while parent.respond_to?(:widget_proxy_set)
            points.merge! parent.widget_proxy_set.entry_points.dup
            parent = parent.superclass
          end
          points
        end

        def enter_widget(entry_point, *args, &block)
          widget = instantiate_widget(widget_entry_points[entry_point])
          result = widget.send(entry_point, *args, &block)

          if widget.subprocessing_enabled? && block_given?
            if method_name = (result.class.respond_to?(:widget_processing_method_name) &&
                              result.class.send(:widget_processing_method_name))
              result.send(method_name, &block)
            else
              raise Widgets::SubprocessingNotSupported, "Return value #{result.inspect} does not support subprocessing"
            end
          end

          result
        rescue ArgumentError => ae
          # ArgumentError: wrong number of arguments (1 for 0)
          #     from ./lib/widgets/proxy_set.rb:73:in `hi'             [0]
          #     from ./lib/widgets/proxy_set.rb:73:in `send'           [1]
          #     from ./lib/widgets/proxy_set.rb:73:in `enter_widget'   [2]
          #     from ./lib/widgets/proxy_set.rb:42:in `hi'             [3]
          if ae.backtrace[0] =~ /#{Regexp::escape "in `#{entry_point}'"}/
            raise ArgumentError, ae.message, caller
          else
            raise ae
          end
        end
      end
    end
  end
end
