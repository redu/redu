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

  context "refresh lectures_count" do
    before do
      @sub = Factory(:subject, :visible => true)
      @sub.finalized = true
      @sub.save
    end

    it "sums 1 after create" do
      ActiveRecord::Observer.with_observers(:lecture_observer) do
        expect {
          lecture = Factory(:lecture, :subject => @sub,
                            :owner => @sub.owner)
        }.should change{ @sub.space.lectures_count }.by(1)
      end
    end

    it "subtracts 1 after destroy" do
      ActiveRecord::Observer.with_observers(:lecture_observer) do
        lecture = Factory(:lecture, :subject => @sub,
                          :owner => @sub.owner)
        expect {
          lecture.destroy
        }.should change{ @sub.space.lectures_count }.by(-1)
      end
    end
  end
end
