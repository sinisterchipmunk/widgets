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
      proc { @k.new("one") }.should_not raise_error(SystemStackError)
    end

    it "should not ignore top-level calls containing ArgumentErrors" do
      proc {
        @k.new("one").one(1)
      }.should raise_error(ArgumentError)
    end

    it "should raise ArgumentError as expected when nested" do
      k = @k
      mock_widget { affects 'nestable'; entry_point :nest; def nest; p k; k.new; end }
#      proc {
        @k.new("nestable").nest do
          one(1)
        end
#      }.should raise_error(ArgumentError)
    end
  end
end