require 'spec_helper'

describe StudentProfile do
  it { should belong_to :user }
  it { should belong_to :subject }
  it { should have_many(:asset_reports).dependent :destroy }
  it { should have_many(:lectures).through :asset_report }

  it { should validate_uniqueness_of(:user_id).scoped :subject_id }

  it "responds to grade"
  it "responds to graduaded"

  context "grade" do
    it "responds to update_grade!" do
      should respond_to :update_grade
    end

    it "updates grade successfully"
  end
end
