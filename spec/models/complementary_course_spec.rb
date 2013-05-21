# -*- encoding : utf-8 -*-
require 'spec_helper'

describe ComplementaryCourse do
  subject { FactoryGirl.create(:complementary_course) }

  it { should validate_presence_of :course }
  it { should validate_presence_of :institution }
  it { should validate_presence_of :year }
  it { should validate_presence_of :workload }

  it { should have_one :education }
end
