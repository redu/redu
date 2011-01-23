require 'spec_helper'

describe Enrollment do
  subject { Factory(:enrollment) }

  it { should belong_to :user }
  it { should belong_to :subject }
  it { should have_one :student_profile }

  it "responds to role" do
    should respond_to :role
  end

  #FIXME não foi possivel testar unicidade
  xit { should validate_uniqueness_of(:user_id).scoped_to :user_id }

  context "callbacks" do
    it "creates a student profile after create" do
      expect {
        subject = Factory(:enrollment)
      }.should change(StudentProfile, :count).by(1)
    end
  end

end
