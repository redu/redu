# -*- encoding : utf-8 -*-
require 'spec_helper'

module StatusService
  describe StatusEntityService do
    subject { StatusEntityService.new(statusable: statusable) }
    let(:statusable) { FactoryGirl.create(:user) }
    let!(:statuses) do
      FactoryGirl.create_list(:activity, 2, statusable: statusable)
    end

    describe "#destroy" do

      it "should destroy statusable's statuses" do
        expect {
          subject.destroy
        }.to change(Status, :count).by(-statuses.length)
      end
    end

    describe "#statuses" do
      it "should return statusable's statuses" do
        subject.statuses.to_set.should == statuses.to_set
      end
    end
  end
end
