require 'spec_helper'

describe Widgets do
  it "should be configurable" do
    Widgets.configure do |config|
      config.should be_kind_of(Widgets::Configuration)
    end
  end

  context "when included" do
    subject do
      Class.new do
        include Widgets

        def id
          @id || raise("No ID!")
        end
      end.new
    end

    it "should load widgets" do
      Widgets.configuration.load_paths = File.join(File.dirname(__FILE__), "../widgets")
      Widgets.load!
      defined?(TestWidget).should_not be_nil
    end

    it "should not override #process if it already exists" do
      Class.new do
        def process; 100; end
        include Widgets
      end.new.process.should == 100
    end

    it "should raise Widgets::ProcessingError if block omitted" do
      proc { subject.process }.should raise_error(Widgets::ProcessingError)
    end

    it "should rename #process as needed" do
      subject.class.process_with :setup

      subject.setup { @id = 1 }
      subject.id.should == 1

      # cheating with a second test, so sue me
      subject.setup { |s| s.instance_variable_set("@id", 2) }
      subject.id.should == 2
    end

    it "should do indirect processing" do
      subject.process { |subj| subj.instance_variable_set("@id", 1) }

      subject.id.should == 1
    end

    it "should do direct processing" do
      subject.process { @id = 1 }

      subject.id.should == 1
    end
  end
end
