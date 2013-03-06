require 'spec_helper'

describe LectureObserver do
  context "logger" do
    it "logs update" do
      ActiveRecord::Observer.with_observers(:lecture_observer) do
        expect {
          sub = Factory(:subject, :visible => true)
          sub.finalized = true
          sub.save
          lecture = Factory(:lecture, :subject => sub,
                             :owner => sub.owner)
        }.should change(Log, :count).by(1)
      end
    end
  end

  context "seminar lecture" do
    it "create with state converted" do
      ActiveRecord::Observer.with_observers(:lecture_observer) do
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
