require 'spec_helper'

describe "Widget subprocessing" do
  context "with subprocessing disabled" do
    before(:each) { mock_widget("mock") { affects(:parent); disable_subprocessing!; entry_point(:entry); def entry; parent; end } }

    it "should be disabled" do
      mock_widget("mock").subprocessing_enabled?.should be_false
    end

    it "should not attempt to perform subprocessing" do
      $spec_counter = 0
      parent.process { $spec_counter += 1; entry { $spec_counter += 2; entry { $spec_counter += 3 } } }

      $spec_counter.should == 1
    end
  end

  context "by default" do
    before(:each) { mock_widget("mock") { affects(:parent); entry_point(:entry); def entry; parent; end } }

    it "should be enabled" do
      mock_widget("mock").subprocessing_enabled?.should be_true
    end

    context "when not supported" do
      before(:each) { mock_widget("mock") { def entry; nil; end } }

      context "when omitting a subprocessing block" do
        before(:each) do
          $spec_counter = 0
          parent.process { $spec_counter += 1; entry }
        end

        it "should skip subprocessing" do
          $spec_counter.should == 1
        end
      end

      context "when given a subprocessing block" do
        it "should perform subprocessing" do
          proc { parent.process { entry { entry { } } } }.should raise_error(Widgets::SubprocessingNotSupported)
        end
      end
    end

    context "when supported" do
      context "when omitting a subprocessing block" do
        before(:each) do
          $spec_counter = 0
          parent.process { $spec_counter += 1; entry }
        end

        it "should skip subprocessing" do
          $spec_counter.should == 1
        end
      end

      context "when given a subprocessing block" do
        before(:each) do
          $spec_counter = 0
          parent.process { $spec_counter += 1; entry { $spec_counter += 2; entry { $spec_counter += 3 } } }
        end

        it "should perform subprocessing" do
          $spec_counter.should == 6
        end
      end
    end
  end
end
