require 'spec_helper'

describe UserCourseAssociationObserver do
  context "when UserCourseAssociation" do
    xit "logs approval" do
      ActiveRecord::Observer.with_observers(:user_course_association_observer) do
        uca = Factory.build(:user_course_association)
        expect {
          uca.save
          uca.approve!
        }.should change(uca.logs, :count).by(1)
      end
    end
  end

  context "mailer" do
    before do
      UserNotifier.delivery_method = :test
      UserNotifier.perform_deliveries = true
      UserNotifier.deliveries = []
    end

    context "when on approval list" do
      it "delivers approval notification" do
        course = Factory(:course, :subscription_type => 2)
        user = Factory(:user)

      ActionMailer::Base.register_observer(UserNotifierObserver)
        ActiveRecord::Observer.with_observers(:user_course_association_observer) do
          expect {
            course.join(user)
          }.should change(UserNotifier.deliveries, :count).by(1)
        end
      end
    end

    context "when open course" do
      it "cant deliver any e-mail" do
        course = Factory(:course)
        user = Factory(:user)

        ActionMailer::Base.register_observer(UserNotifierObserver)
        ActiveRecord::Observer.with_observers(:user_course_association_observer) do
          expect {
            course.join(user)
          }.should_not change(UserNotifier.deliveries, :count)
        end
      end
    end
  end
end
