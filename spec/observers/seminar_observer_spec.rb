require 'spec_helper'

describe SeminarObserver do
  context "seminar lecture" do
    it "create with state converted" do
      ActiveRecord::Observer.with_observers(:seminar_observer) do
        sub = Factory(:subject, :visible => true)
        sub.finalized = true
        sub.save

        lecture = Factory(:lecture, :subject => sub,
                          :lectureable => Factory(:seminar_youtube))
        lecture.reload

        lecture.lectureable.converted?.should be_true
      end
    end
  end
end
