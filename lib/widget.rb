require File.join(File.dirname(__FILE__), "widget/class_methods")

class Widget
  autoload :ProxyModule, File.join(File.dirname(__FILE__), "widget/proxy_module")
  extend Widget::ClassMethods

  attr_reader :parent
  delegate :proxy_module, :to => "self.class"

  def initialize(parent)
    @parent = parent
  end

  def eigenclass
    class << self; self; end
  end
end
