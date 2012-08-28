require 'spec_helper'

describe HierarchyStatusesJob do
  context "when status or course doesnt not exist" do
    it "should not raise RecordNotFound" do
      expect {
        HierarchyStatusesJob.new(:status_id => 123, :course_id => 456).perform
      }.to_not raise_error ActiveRecord::RecordNotFound
    end
  end
end
