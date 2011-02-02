require 'spec_helper'

describe Widget::ProxyModule do
  context "when included" do
    subject do
      Class.new do
        proxy = Widget::ProxyModule.new
        proxy.shares :tml_variables
        proxy.shares :variable_definitions => []
        include proxy
      end.new
    end

    it "should create shared variable accessors" do
      subject.tml_variables = 1
      subject.tml_variables.should == 1

      subject.variable_definitions.should == []
    end
  end
end
