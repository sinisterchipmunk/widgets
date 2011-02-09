require 'spec_helper'

describe Widget do
  context "affecting a class which inherits from another Widgetized class" do
    subject do
      mock_widget("parent_mock") do
        affects :parent
        entry_point :parent_method
        def parent_method
          parent
        end
      end

      mock_widget("child_mock") do
        affects :child
        entry_point :child_method
        def child_method
          parent
        end
      end

      subclass = Class.new(parent_class) { def self.name; "child"; end }
      Widgets.force(subclass.name, subclass)
      subclass.new
    end

    # Not sure we should be testing this.
#    it "should include both entry points" do
#      subject.widget_entry_points.keys.should == [:parent_method, :child_method]
#    end

    it "should receive #parent_method" do
      subject.parent_method.should == subject
    end

    it "should receive #child_method" do
      subject.child_method.should == subject
    end
  end
end
