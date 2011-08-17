require 'spec_helper'

describe LectureObserver do
  context "logger" do
    it "logs update" do
      ActiveRecord::Observer.with_observers(:lecture_observer) do
        expect {
          sub = Factory(:subject)
          sub.finalized = true
          sub.turn_visible!
          sub.save
          lecture = Factory(:lecture, :subject => sub,
                             :owner => sub.owner)
        }.should change(Log, :count).by(1)
      end
    end
  end
end
