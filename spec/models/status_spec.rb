require 'spec_helper'

describe Status do
  it { should belong_to(:statusable) }
  it { should have_many(:observers).through(:status_user_associations) }
  it { should have_many(:status_user_associations).dependent(:destroy) }
end
