# -*- encoding : utf-8 -*-
require 'spec_helper'

describe UserStatusesJob do
  context "when status or course doesnt not exist" do
    it "should not raise RecordNotFound" do
      expect {
        UserStatusesJob.new(:user_id => 123, :statys_id => 456).perform
      }.to_not raise_error ActiveRecord::RecordNotFound
    end
  end
end

