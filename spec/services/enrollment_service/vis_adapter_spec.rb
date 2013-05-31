# -*- encoding : utf-8 -*-
require 'spec_helper'

module EnrollmentService
  describe VisAdapter do
    it "should be a ::VisAdapter" do
      described_class.new.should be_a(::VisAdapter)
    end

    describe "adapter methods" do
      let(:items) { FactoryGirl.create_list(:enrollment, 2, subject: nil) }
      let(:items_arel) { Enrollment.limit(2) }
      include_examples "vis adapter method", :notify_enrollment_creation,
        "enrollment"
      include_examples "vis adapter method", :notify_enrollment_removal,
        "remove_enrollment"
      include_examples "vis adapter method", :notify_remove_subject_finalized,
        "remove_subject_finalized"
      include_examples "vis adapter method", :notify_subject_finalized,
        "subject_finalized"
    end
  end
end
