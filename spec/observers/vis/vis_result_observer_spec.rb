require 'spec_helper'

describe VisResultObserver do
  subject { Factory(:result) }

  describe "before update" do
    before do
      subject.start!
    end

    context "when updating to finalized" do

      it "should call VisClient.notify_delayed with result" do
        VisClient.should_receive(:notify_delayed).
          with("/hierarchy_notifications.json", "exercise_finalized", subject)

        ActiveRecord::Observer.with_observers(:vis_result_observer) do
          subject.finalize!
        end
      end
    end

    context "when updating another attribute (started_at)" do
      before do
        subject.finalize!
      end

      it "should not call VisClient.notify_delayed" do
        subject
        VisClient.should_not_receive(:notify_delayed)

        ActiveRecord::Observer.with_observers(:vis_result_observer) do
          subject.update_attributes(:started_at => Time.now)
        end
      end
    end
  end
end
