require File.join(File.dirname(__FILE__), "widget/class_methods")

class Widget
  autoload :ProxyModule, File.join(File.dirname(__FILE__), "widget/proxy_module")
  extend Widget::ClassMethods

  attr_reader :parent
  delegate :proxy_module, :entry_points, :to => 'self.class'

  def initialize(parent)
    @parent = parent
  end

  def eigenclass
    class << self; self; end
  end

  def subprocessing_enabled?
    !(@subprocessing_disabled ||= self.class.subprocessing_disabled?)
  end

  def subprocessing_disabled?
    !!(@subprocessing_disabled ||= self.class.subprocessing_disabled?)
  end

  def disable_subprocssing!
    @subprocessing_disabled = true
  end

  def enable_subprocessing!
    @subprocessing_disabled = false
  end

  # Any method missing from this widget will be delegated into #parent.
  #
  # The parent's methods are not known until runtime, so delegation methods cannot be eagerly
  # generated until instantiation and it's extraordinarily slow to generate delegation methods
  # on the fly. Using #method_missing is the happy middle ground.
  #
  def method_missing(name, *args, &block)
    # Don't delegate missing entry points or they'll recurse infinitely. Also don't delegate if
    # parent doesn't respond_to name, or we risk the same.
    if (_parent = parent).respond_to?(name) && !entry_points.include?(name.to_s)
      return _parent.send(name, *args, &block)
    end

    # let super raise NoMethodError
    super
  end

  # A Widget will respond to any method its #parent responds to, because calls to those methods
  # will be delegated to its parent.
  #
  # The parent's methods are not known until runtime, so delegation methods cannot be eagerly
  # generated until instantiation and it's extraordinarily slow to generate delegation methods
  # on the fly. Using #method_missing is the happy middle ground.
  #
  def respond_to?(*a, &b)
    super || parent.respond_to?(*a, &b)
  end
end
