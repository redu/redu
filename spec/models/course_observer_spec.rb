require 'spec_helper'

describe CourseObserver do
  context "Logger" do
    it "logs the creation" do
      ActiveRecord::Observer.with_observers(:course_observer) do
        course = Factory.build(:course)

        expect {
          course.save
        }.should change(course.logs, :count).by(1)
      end
    end
  end
end
