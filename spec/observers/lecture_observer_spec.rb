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
        }.to change(Log, :count).by(1)
      end
    end
  end
end
