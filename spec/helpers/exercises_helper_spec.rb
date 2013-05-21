# -*- encoding : utf-8 -*-
require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the ExercisesHelper. For example:
#
# describe ExercisesHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe ExercisesHelper do
  context "period of time" do
    it "should generate zero text if less than a second" do
      helper.period_of_time(0.1).should == { :unit => 'segundos', :value => 0 }
    end

    it "should generate time in second if less than a minute" do
      helper.period_of_time(30).should == { :unit => 'segundos', :value => 30}
    end

    it "should generate time in minutes if more than a minute" do
      helper.period_of_time(61).should == { :unit => 'minutos', :value => 1}
    end
  end
end
