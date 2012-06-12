require 'spec_helper'

describe UserStatusesJob do
  context "when status or course doesnt not exist" do
    it "should not raise RecordNotFound" do
      expect {
        UserStatusesJob.new(123,456).perform
      }.to_not raise_error ActiveRecord::RecordNotFound
    end
  end
end

