require 'spec_helper'

describe Widget do
  subject { mock_widget("mock") { } }

  it "should have a proxy module" do
    subject.proxy_module.should be_kind_of(Widget::ProxyModule)
  end

#  it "should raise error when a symbol is not given as a class name" do
#    proc { mock_widget("mock") { affects "parent" } }.should raise_error(Widgets::InvalidClassName)
#  end
  it "should not raise error when a symbol is not given as a class name" do
    proc { mock_widget("mock") { affects "parent" } }.should_not raise_error(Widgets::InvalidClassName)
  end

  it "should affect its parent" do
    subject.class_eval { affects :parent }

    parent_class.should include(Widgets.mapping(parent_class.name))
    Widgets.mapping(parent_class.name).should include(mock_widget("mock").proxy_module)
  end

  it "should delegate shared variable accessors to parent" do
    widget_instance = parent.instantiate_widget(mock_widget("mock") do
      affects :parent
      shares :varname
    end)

    widget_instance.varname = 1
    parent.varname.should == 1
  end
end
