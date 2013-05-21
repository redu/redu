# -*- encoding : utf-8 -*-
require 'spec_helper'

describe HighSchool do
  subject { FactoryGirl.create(:high_school) }

  it { should validate_presence_of :institution }
  it { should validate_presence_of :end_year }

  it { should have_one :education }
end
