# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Choice do
  subject { FactoryGirl.create(:choice) }

  it { should belong_to(:alternative) }
  it { should belong_to(:user) }
  it { should belong_to(:question) }
  it { should validate_uniqueness_of(:user_id).scoped_to(:question_id) }

  it_should_behave_like 'have unique index database'
end
