require 'spec_helper'

describe "Widget entry points" do
  it "should delegate to entry points from parent" do
    mock_widget("mock") do
      affects :parent
      entry_point :entry
      def entry; self; end
    end

    parent.entry.should inherit(Widget)
  end
end
