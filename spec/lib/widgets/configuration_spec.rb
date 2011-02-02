require 'spec_helper'

describe Widgets::Configuration do
  context "with default values" do
    it "should set load paths predictably" do
      # make the load paths something testable
      lp = $LOAD_PATH.dup
      $LOAD_PATH.clear
      $LOAD_PATH.push('/a', '/b')

      Widgets::Configuration.new.load_paths.should == ['/a/widgets', '/b/widgets']

      # reset load paths
      $LOAD_PATH.clear
      lp.each { |p| $LOAD_PATH.push p }
    end

    it "should toggle widget logging" do
      subject.widget_logging_enabled = true
      subject.widget_logging_enabled?.should be_true
    end

    it "should disable widget logging by default" do
      subject.widget_logging_enabled?.should be_false
    end

    it "should use internal logger by default" do
      subject.logger.should be_kind_of(Widgets::StderrLogger)
    end
  end
end
