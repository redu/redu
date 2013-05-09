require 'spec_helper'

describe SpaceObserver do
  context "Logger" do
    it "logs creation" do
      ActiveRecord::Observer.with_observers(:space_observer) do
        space = Factory.build(:space)
        expect {
          space.save
        }.to change(space.logs, :count).by(1)
      end
    end
  end

  context "mailer" do
    before do
      UserNotifier.delivery_method = :test
      UserNotifier.perform_deliveries = true
      UserNotifier.deliveries = []
    end

    it "notifies creation" do
      @course = Factory(:course)
      users = 3.times.inject([]) do |acc,i|
        u = Factory(:user)
        @course.join(u)
        acc << u
      end

      ActiveRecord::Observer.with_observers(:space_observer) do
        expect {
          Factory(:space, :owner => @course.owner, :course => @course)
        }.to change(UserNotifier.deliveries, :count).by(4)
      end
    end
  end
end
