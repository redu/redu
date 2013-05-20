# -*- encoding : utf-8 -*-
require 'spec_helper'

describe CourseObserver do
  context "Logger" do
    it "logs the creation" do
      ActiveRecord::Observer.with_observers(:course_observer) do
        course = Factory.build(:course)

        expect {
          course.save
        }.to change(course.logs, :count).by(1)
      end
    end
  end

  context "when destroying" do
    context "with an associated plan" do
      it "should persist course attributes" do
        subject = Factory(:plan)
        course = subject.billable

        ActiveRecord::Observer.with_observers :course_observer do
          subject.billable.destroy
          subject.reload.billable_audit["name"].should == course.name
          subject.reload.billable_audit["path"].should == course.path
        end
      end
    end

    context "withdout an associated plan" do
      it "should fail silently" do
        subject = Factory(:course)

        ActiveRecord::Observer.with_observers :course_observer do
          expect {
            subject.destroy
          }.to_not raise_error
        end
      end
    end

  end
end
