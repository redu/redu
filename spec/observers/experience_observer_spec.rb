# -*- encoding : utf-8 -*-
require 'spec_helper'

describe ExperienceObserver do
  context "logger" do
    it "logs creation" do
      ActiveRecord::Observer.with_observers(:experience_observer) do
        expect {
          FactoryGirl.create(:experience)
        }.to change(Log, :count).by(1)
      end
    end
  end
end
