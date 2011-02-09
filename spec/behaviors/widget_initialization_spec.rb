require 'spec_helper'

describe Widget do
  context "with a parent whose name is determined at runtime" do
    before(:each) {
      @k = Class.new do
        class << self; def name; "base"; end; end

        def initialize(name)
          eigenclass.send(:define_method, name) { name }
          Widgets.force(name, eigenclass)
        end
        include Widgets
      end

      mock_widget { affects 'one'; entry_point :one; def one; 1; end }
    }

    it "should not cause stack level errors" do
      #proc {
        @k.new("one")
      #}.should_not raise_error(SystemStackError)
    end
  end
end