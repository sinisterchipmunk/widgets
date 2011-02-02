require 'spec_helper'

describe Widgets::StderrLogger do
  before(:each) { $_stderr = $stderr; $stderr = StringIO.new("") }
  after(:each) { $stderr = $_stderr }

  it "should warn" do
    subject.warn("message")
    $stderr.string.should == "warn\tmessage\n"
  end

  it "should info" do
    subject.info("message")
    $stderr.string.should == "info\tmessage\n"
  end

  it "should debug" do
    subject.debug("message")
    $stderr.string.should == "debug\tmessage\n"
  end

  it "should error" do
    subject.error("message")
    $stderr.string.should == "error\tmessage\n"
  end
end
