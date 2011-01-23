require 'spec_helper'

describe StudentProfile do
  subject { Factory(:student_profile) }

  it { should belong_to :user }
  it { should belong_to :subject }
  it { should belong_to :enrollment }
  it { should have_many(:asset_reports).dependent :destroy }
  it { should have_many(:lectures).through :asset_reports }

  # FIXME Erro de tradução
  xit { should validate_uniqueness_of(:user_id).scoped_to :subject_id }

  it "responds to grade" do
    should respond_to :grade
  end

  it "responds to graduated" do
    should respond_to :graduaded
  end

  context "callbacks" do
    it "creates all assets reports after create" do
      lectures = (1..3).collect { Factory(:lecture) }
      subject_entity = Factory(:subject, :lectures => lectures)
      expect {
        Factory(:student_profile, :subject => subject_entity)
      }.should change {
        AssetReport.count
      }.by(subject_entity.lectures.count)
    end
  end

  context "grade" do
    it "responds to update_grade!" do
      should respond_to :update_grade!
    end

    it "updates grade successfully" do
      lectures = (1..3).collect { Factory(:lecture) }
      subject_entity = Factory(:subject, :lectures => lectures)
      subject = Factory(:student_profile)
      subject.asset_reports.each { |a| a.done! }
      expect {
        subject.update_grade!
      }.should change(subject, :grade).by(100)
      subject.graduaded.should be_true
    end
  end
end
