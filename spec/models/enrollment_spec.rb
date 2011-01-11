require 'spec_helper'

describe Enrollment do
  subject { Factory(:enrollment) }

  it { should belong_to :user }
  it { should belong_to :subject }
  it { should have_one :student_profile }

  #FIXME não foi possivel testar unicidade
  xit { should validate_uniqueness_of(:user_id).scoped_to :user_id }

end
