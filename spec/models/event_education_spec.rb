# -*- encoding : utf-8 -*-
require 'spec_helper'

describe EventEducation do
  subject { Factory(:event_education) }

  it { should validate_presence_of :name }
  it { should validate_presence_of :role }
  it { should validate_presence_of :year }

  it { should have_one :education }

  context "validations" do
    context "validates if role is one of the permitted" do
      %w(participant speaker organizer).each do |r|
        it "validate true if role is #{r}" do
          event = Factory.build(:event_education, :role => r)
          event.should be_valid
        end
      end

      it "validate false if role is not an allowed value" do
          event = Factory.build(:event_education, :role => "not_allowed")
          event.should_not be_valid
          event.errors[:role].should_not be_empty
      end
    end
  end
end
