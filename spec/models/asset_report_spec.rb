require 'spec_helper'

describe AssetReport do
  it { should belong_to :student_profile }
  it { should belong_to :lecture }
  it { should belong_to :subject }

  it "responds to done" do
    should respond_to :done
  end

  it "responds to done_for" do
    should respond_to :done_for
  end

  context "done for" do
    subject { Factory(:asset_report) }
    it "is successfuly" do

      expect {
        lecture.done_for(user)
      }
    end
  end
end
