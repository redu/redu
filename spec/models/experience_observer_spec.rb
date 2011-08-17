require 'spec_helper'

describe ExperienceObserver do
  context "logger" do
    it "logs creation" do
      ActiveRecord::Observer.with_observers(:experience_observer) do
        expect {
          Factory(:experience)
        }.should change(Log, :count).by(1)
      end
    end
  end
end
