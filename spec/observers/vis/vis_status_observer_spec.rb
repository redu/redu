require 'spec_helper'

describe VisStatusObserver do
  context "after create" do
    context "an activity or help in a lecture wall (statusable Lecture)" do
      let!(:lecture) { Factory(:lecture) }
      let(:help) { Factory.build(:help, :statusable => lecture) }
      it "should call VisClient.notify_delayed" do
        VisClient.should_receive(:notify_delayed).
          with("/hierarchy_notifications.json", help.type.downcase,
               help.becomes(Status))

        ActiveRecord::Observer.with_observers(:vis_status_observer) do
          help.save
        end
      end
    end

    context "an activity or help in a space wall (statusable Space)" do
      let!(:space) { Factory(:space) }
      let(:activity) { Factory.build(:activity, :statusable => space) }
      it "should call VisClient.notify_delayed" do
        VisClient.should_receive(:notify_delayed).
          with("/hierarchy_notifications.json", activity.type.downcase,
               activity.becomes(Status))

        ActiveRecord::Observer.with_observers(:vis_status_observer) do
          activity.save
        end
      end
    end

    context "an answer in a lecture wall" do
      let!(:lecture) { Factory(:lecture) }
      let!(:help) { Factory(:help, :statusable => lecture) }
      let(:answer) { Factory.build(:answer, :statusable => help,
                                  :in_response_to => help) }
      it "should call VisClient.notify_delayed" do
        VisClient.should_receive(:notify_delayed).
          with("/hierarchy_notifications.json", "answered_help",
               answer.becomes(Status))

        ActiveRecord::Observer.with_observers(:vis_status_observer) do
          answer.save
        end
      end
    end

    context "an aswer in a space wall" do
      let!(:space) { Factory(:space) }
      let!(:activity) { Factory(:activity, :statusable => space) }
      let(:answer) { Factory.build(:answer, :statusable => activity,
                                   :in_response_to => activity) }
      it "should call VisClient.notify_delayed" do
        VisClient.should_receive(:notify_delayed).
          with("/hierarchy_notifications.json", "answered_activity",
               answer.becomes(Status))

        ActiveRecord::Observer.with_observers(:vis_status_observer) do
          answer.save
        end
      end
    end
  end

  context "after destroy" do
    context "an activity or help in a lecture wall (statusable Lecture)" do
      let!(:lecture) { Factory(:lecture) }
      let(:help) { Factory(:help, :statusable => lecture) }
      it "should call VisClient.notify_delayed" do
        VisClient.should_receive(:notify_delayed).
          with("/hierarchy_notifications.json",
               "remove_"+help.type.downcase,
               help.becomes(Status))

        ActiveRecord::Observer.with_observers(:vis_status_observer) do
          help.destroy
        end
      end
    end

    context "an activity or help in a space wall (statusable Space)" do
      let!(:space) { Factory(:space) }
      let(:activity) { Factory(:activity, :statusable => space) }
      it "should call VisClient.notify_delayed" do
        VisClient.should_receive(:notify_delayed).
          with("/hierarchy_notifications.json",
               "remove_"+activity.type.downcase,
               activity.becomes(Status))

        ActiveRecord::Observer.with_observers(:vis_status_observer) do
          activity.destroy
        end
      end
    end

    context "an answer in a lecture wall" do
      let!(:lecture) { Factory(:lecture) }
      let!(:activity) { Factory(:activity, :statusable => lecture) }
      let(:answer) { Factory(:answer, :statusable => activity,
                                  :in_response_to => activity) }
      it "should call VisClient.notify_delayed" do
        VisClient.should_receive(:notify_delayed).
          with("/hierarchy_notifications.json", "remove_answered_activity",
               answer.becomes(Status))

        ActiveRecord::Observer.with_observers(:vis_status_observer) do
          answer.destroy
        end
      end
    end

    context "an aswer in a space wall" do
      let!(:space) { Factory(:space) }
      let!(:activity) { Factory(:activity, :statusable => space) }
      let(:answer) { Factory(:answer, :statusable => activity,
                                   :in_response_to => activity) }
      it "should call VisClient.notify_delayed" do
        VisClient.should_receive(:notify_delayed).
          with("/hierarchy_notifications.json", "remove_answered_activity",
               answer.becomes(Status))

        ActiveRecord::Observer.with_observers(:vis_status_observer) do
          answer.destroy
        end
      end
    end

  end
end
