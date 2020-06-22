# -*- encoding : utf-8 -*-
require 'spec_helper'

describe SeminarObserver do
  context "seminar lecture" do
    it "create with state converted" do
      ActiveRecord::Observer.with_observers(:seminar_observer) do
        sub = FactoryBot.create(:subject, :visible => true)
        sub.finalized = true
        sub.save

        lecture = FactoryBot.create(:lecture, :subject => sub,
                          :lectureable => FactoryBot.create(:seminar_youtube))
        lecture.reload

        lecture.lectureable.converted?.should be_true
      end
    end
  end
end
