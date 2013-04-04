require 'spec_helper'

describe VisLectureObserver do
  describe "before destroy" do
    context "when lectureable is not an Exercise" do
      subject { Factory(:lecture, :lectureable => Factory(:page)) }

      it "should not raise error" do
        ActiveRecord::Observer.with_observers(:vis_lecture_observer) do
          expect {
            subject.destroy
          }.to_not raise_error
        end
      end

      it "should not call VisClient.notify_delayed" do
        subject
        VisClient.should_not_receive(:notify_delayed)

        ActiveRecord::Observer.with_observers(:vis_lecture_observer) do
          subject.destroy
        end
      end
    end

    context "when lectureable is an Exercise" do
      subject { Factory(:lecture, :lectureable => Factory(:exercise)) }
      let(:exercise) { subject.lectureable }
      let(:finalized_results) do
        (1..3).collect do
          Factory(:finalized_result, :exercise => exercise)
        end
      end
      let!(:unfinalized_results) do
        (1..3).collect { Factory(:result, :exercise => exercise) }
      end

      it "should call VisClient.notify_delayed with finalized results" do
        VisClient.should_receive(:notify_delayed).
          with("/hierarchy_notifications.json",
               "remove_exercise_finalized", finalized_results)

        ActiveRecord::Observer.with_observers(:vis_lecture_observer) do
          subject.destroy
        end
      end
    end
  end
end
