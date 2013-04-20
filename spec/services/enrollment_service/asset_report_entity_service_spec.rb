require 'spec_helper'

module EnrollmentService
  describe AssetReportEntityService do
    subject { AssetReportEntityService.new(:lecture => lectures) }
    let(:subjects) { 2.times.map { Factory(:subject, :space => nil) } }
    let!(:lectures) do
      subjects.map do |subj|
        3.times.map { Factory(:lecture, :subject => subj, :owner => subj.owner) }
      end.flatten
    end

    before do
      EnrollmentEntityService.new(:subject => subjects).
        create(3.times.collect { [Factory(:user), Role[:member]] })
    end

    it "should wrap a collection of lectures" do
      subject.lectures.should == lectures
    end

    context "#create" do
      let(:columns) { [:subject_id, :lecture_id, :enrollment_id] }
      it "should delegate to the importer with correct arguments" do
        values = []
        enrollments = subjects.map(&:enrollments).flatten

        enrollments.each do |enrollment|
          enrollment.subject.lectures.each do |l|
            values << [l.subject_id, l.id, enrollment.id]
          end
        end

        subject.importer.should_receive(:insert).with(values)
        subject.create
      end

      it "should accept an optional ARel query that return enrollments" do
        values = []
        enrollments = subjects.map(&:enrollments).flatten

        enrollments.each do |enrollment|
          enrollment.subject.lectures.each do |l|
            values << [l.subject_id, l.id, enrollment.id]
          end
        end

        subject.importer.should_receive(:insert).with(values)
        subject.create(Enrollment.where(:subject_id => subjects))
      end

      it "should update grades"
    end
  end
end
