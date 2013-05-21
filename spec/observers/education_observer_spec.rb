# -*- encoding : utf-8 -*-
require 'spec_helper'

describe EducationObserver do
  context "logger" do
    it "logs creation" do
      ActiveRecord::Observer.with_observers(:education_observer) do
        expect {
          FactoryGirl.create(:education)
        }.to change(Log, :count).by(1)
      end
    end
  end
end
