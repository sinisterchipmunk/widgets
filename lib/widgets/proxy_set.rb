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
  end
end
