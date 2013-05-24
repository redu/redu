# -*- encoding : utf-8 -*-
require 'spec_helper'

module EnrollmentService
  describe VisAdapter do
    let(:vis_adapter) { VisAdapter.new }
    let(:enrollments) { 2.times.map { FactoryGirl.create(:enrollment, subject: nil) } }
    let(:enrollments_arel) { Enrollment.limit(2) }

    describe ".initialize" do
      context "without arguments" do
        let(:vis_adapter) { VisAdapter.new }

        it "should set vis_client" do
          vis_adapter.vis_client.should == VisClient
        end

        it "should set url" do
          vis_adapter.url.should == "/hierarchy_notifications.json"
        end
      end

      context "with vis_client and url arguments" do
        let(:vis_adapter) do
          VisAdapter.new(vis_client: Enrollment, url: "/new_url.json")
        end

        it "should set vis_client" do
          vis_adapter.vis_client.should == Enrollment
        end

        it "should set url" do
          vis_adapter.url.should == "/new_url.json"
        end
      end
    end

    describe "#notify_enrollment_creation" do
      context "with an array" do
        it "should invoke VisClient with correct arguments" do
          set_vis_client_expectation("enrollment", enrollments)
          vis_adapter.notify_enrollment_creation(enrollments)
        end
      end

      context "with an ActiveRecord::Relation" do
        it "should invoke VisClient with correct arguments" do
          set_vis_client_expectation("enrollment", enrollments)
          vis_adapter.notify_enrollment_creation(enrollments_arel)
        end
      end
    end

    describe "#notify_enrollment_removal" do
      context "with an array" do
        it "should invoke VisClient with correct arguments" do
          set_vis_client_expectation("remove_enrollment", enrollments)
          vis_adapter.notify_enrollment_removal(enrollments)
        end
      end

      context "with an ActiveRecord::Relation" do
        it "should invoke VisClient with correct arguments" do
          set_vis_client_expectation("remove_enrollment", enrollments)
          vis_adapter.notify_enrollment_removal(enrollments_arel)
        end
      end
    end

    describe "#notify_remove_subject_finalized" do
      context "with an array" do
        it "should invoke VisClient with correct arguments" do
          set_vis_client_expectation("remove_subject_finalized", enrollments)
          vis_adapter.notify_remove_subject_finalized(enrollments)
        end
      end

      context "with an ActiveRecord::Relation" do
        it "should invoke VisClient with correct arguments" do
          set_vis_client_expectation("remove_subject_finalized", enrollments)
          vis_adapter.notify_remove_subject_finalized(enrollments_arel)
        end
      end
    end

    describe "#notify_subject_finalized" do
      context "with an array" do
        it "should invoke VisClient with correct arguments" do
          set_vis_client_expectation("subject_finalized", enrollments)
          vis_adapter.notify_subject_finalized(enrollments)
        end
      end

      context "with an ActiveRecord::Relation" do
        it "should invoke VisClient with correct arguments" do
          set_vis_client_expectation("subject_finalized", enrollments)
          vis_adapter.notify_subject_finalized(enrollments_arel)
        end
      end
    end

    def set_vis_client_expectation(message, enrollments)
      VisClient.should_receive(:notify_delayed).
        with("/hierarchy_notifications.json", message, enrollments)
    end
  end
end
