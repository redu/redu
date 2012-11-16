require 'spec_helper'

describe UserCourseAssociationObserver do
  context "when UserCourseAssociation" do
    before do
      @uca = Factory.build(:user_course_association)
    end

    xit "logs approval" do
      ActiveRecord::Observer.with_observers(:user_course_association_observer) do
        expect {
          @uca.save
          @uca.approve!
        }.should change(@uca.logs, :count).by(1)
      end
    end

    it "should update course attribute updated_at" do
      ActiveRecord::Observer.with_observers(
        :user_course_association_observer) do
          @uca.save
          expect {
            @uca.approve!
          }.should change(@uca.course, :updated_at)
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
      # Colocar essa lógica no observer
      xit "delivers approval notification" do
        course = Factory(:course, :subscription_type => 2)
        user = Factory(:user)

        ActiveRecord::Observer.with_observers(:user_course_association_observer) do
          expect {
            course.join(user)
          }.should change(UserNotifier.deliveries, :count).by(1)
        end
      end
    end

    context "when approving to an open course" do
      # Colocar essa lógia no observer
      xit "cant deliver any e-mail" do
        course = Factory(:course)
        user = Factory(:user)

        ActiveRecord::Observer.with_observers(:user_course_association_observer) do
          expect {
            course.join(user)
          }.should_not change(UserNotifier.deliveries, :count)
        end
      end
    end

    context "when inviting member" do
      it "delivers notification" do
        course = Factory(:course)
        user = Factory(:user)

        ActiveRecord::Observer.with_observers(:user_course_association_observer) do
          expect {
            course.invite(user)
          }.should change(UserNotifier.deliveries, :count).by(1)
        end
      end

      context "on a closed course" do
        it "delivers notification" do
          course = Factory(:course, :subscription_type => 2)
          user = Factory(:user)

          ActiveRecord::Observer.with_observers(:user_course_association_observer) do
            expect {
              course.invite(user)
            }.should change(UserNotifier.deliveries, :count).by(1)
          end
        end
      end
    end
  end
end
