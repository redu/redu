# -*- encoding : utf-8 -*-
require 'spec_helper'

describe LectureObserver do
  context "logger" do
    it "logs update" do
      ActiveRecord::Observer.with_observers(:lecture_observer) do
        expect {
          sub = FactoryBot.create(:subject, :visible => true)
          sub.finalized = true
          sub.save
          lecture = FactoryBot.create(:lecture, :subject => sub,
                             :owner => sub.owner)
        }.to change(Log, :count).by(1)
      end
    end
  end
end
