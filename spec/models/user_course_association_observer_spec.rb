require 'spec_helper'

describe UserCourseAssociationObserver do
  context "when UserCourseAssociation" do
    it "logs approval" do
      ActiveRecord::Observer.with_observers(:user_course_association_observer) do
        uca = Factory.build(:user_course_association)
        expect {
          uca.save
          uca.approve!
        }.should change(uca.logs, :count).by(1)
      end
    end
  end
end
