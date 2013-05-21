# -*- encoding : utf-8 -*-
require 'spec_helper'

describe SeminarObserver do
  context "seminar lecture" do
    it "create with state converted" do
      ActiveRecord::Observer.with_observers(:seminar_observer) do
        sub = FactoryGirl.create(:subject, :visible => true)
        sub.finalized = true
        sub.save

        lecture = FactoryGirl.create(:lecture, :subject => sub,
                          :lectureable => FactoryGirl.create(:seminar_youtube))
        lecture.reload

        lecture.lectureable.converted?.should be_true
      end
    end
  end
end
