require 'spec_helper'

describe LogObserver do
  context "after create" do
    before do
      @uca = Factory(:user_course_association, :state => "approved")
    end

   it "should be performed compounds" do
     ActiveRecord::Observer.with_observers(:log_observer) do
       expect {
         Factory(:log, :logeable => @uca)
       }.should change(CompoundLog, :count).by(1)
     end
   end
  end
end
