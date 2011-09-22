require 'spec_helper'

describe SubjectObserver do
  context "Logger" do
    it "logs the creation" do
      sub = Factory(:subject)
      Factory(:lecture, :subject => sub)

      ActiveRecord::Observer.with_observers(:subject_observer) do
        expect {
          sub.finalized = true
          sub.turn_visible!
          sub.save
          sub.save
        }.should change(sub.logs, :count).by(1)
      end
    end
  end
end
