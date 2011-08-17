require 'spec_helper'

describe SpaceObserver do
  context "Logger" do
    it "logs creation" do
      ActiveRecord::Observer.with_observers(:space_observer) do
        space = Factory.build(:space)
        expect {
          space.save
        }.should change(space.logs, :count).by(1)
      end
    end
  end
end
