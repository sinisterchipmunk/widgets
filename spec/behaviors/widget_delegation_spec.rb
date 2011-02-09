require 'spec_helper'

describe Widget do
  subject { parent { def say_hello; end }.get_widget }

  before(:each) do
    mock_widget do
      affects :parent
      entry_point :get_widget

      def get_widget
        self
      end
    end
  end

  it "should delegate missing methods to its parent" do
    proc { subject.say_hello }.should_not raise_error
  end

  it "should respond_to parent methods" do
    subject.should respond_to(:say_hello)
  end
end