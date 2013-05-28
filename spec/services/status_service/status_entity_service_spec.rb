# -*- encoding : utf-8 -*-
require 'spec_helper'

module StatusService
  describe StatusEntityService do
    subject { StatusEntityService.new(statusable: statusable) }
    let(:statusable) { FactoryGirl.create(:user) }

    describe "#destroy" do
      let(:statuses) do
        FactoryGirl.create_list(:activity, 2, statusable: statusable)
      end

      it "should destroy statusable's statuses" do
        expect {
          subject.destroy
        }.to change(Status, :count).by(-statuses.length)
      end
    end
  end
end
