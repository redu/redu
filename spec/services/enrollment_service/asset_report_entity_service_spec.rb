# -*- encoding : utf-8 -*-
require 'spec_helper'

module EnrollmentService
  module Jobs
    describe AssetReportEntityService do
      subject { AssetReportEntityService.new(lecture: lectures) }
      let(:subjects) { 2.times.map { FactoryGirl.create(:subject, space: nil) } }
      let!(:lectures) do
        subjects.map do |subj|
          3.times.map { FactoryGirl.create(:lecture, subject: subj, owner: subj.owner) }
        end.flatten
      end

      before do
        EnrollmentEntityService.new(subject: subjects).
          create(users: FactoryGirl.create_list(:user, 3))
      end

      it "should wrap a collection of lectures" do
        subject.lectures.should == lectures
      end

      context "#create" do
        let(:columns) { [:subject_id, :lecture_id, :enrollment_id] }
        let(:enrollments) { subjects.map(&:enrollments).flatten }

        it "should delegate to the importer with correct arguments" do
          values = []

          enrollments.each do |enrollment|
            enrollment.subject.lectures.each do |l|
              values << [l.subject_id, l.id, enrollment.id]
            end
          end

          subject.importer.should_receive(:insert).with(values)
          subject.create
        end

        it "should accept enrollments as argument" do
          values = []

          enrollments.each do |enrollment|
            enrollment.subject.lectures.each do |l|
              values << [l.subject_id, l.id, enrollment.id]
            end
          end

          subject.importer.should_receive(:insert).with(values)
          subject.create(enrollments)
        end

        it "should return created asset reports" do
          assets = subject.create(enrollments)

          created_assets = AssetReport.all.reverse[0..(lectures.length *
                                                       enrollments.length)]
          assets.to_set.should == created_assets.to_set
        end
        it "should update grades"
      end

      context "#destroy" do
        let!(:asset_reports) do
          lectures.map do |l|
            l.subject.enrollments.map do |enrollment|
              FactoryGirl.create(:asset_report, enrollment: enrollment, lecture: l)
            end.flatten
          end.flatten
        end
        let(:enrollments) { subjects.map(&:enrollments).flatten }

        it "should accept a single enrollment as argument" do
          expect {
            subject.destroy(enrollments.first)
          }.to_not raise_error
        end

        it "should remove the correct quantity of asset reports" do
          expect {
            subject.destroy(enrollments)
          }.to change(AssetReport, :count).by(-asset_reports.length)
        end

        it "should remove the correct asset reports" do
          subject.destroy(enrollments)
          enrollments.map(&:asset_reports).flatten.to_set.should_not \
            be_superset asset_reports.to_set
        end
      end

      describe "#get_asset_reports_for" do
        let(:asset_reports) do
          lectures.map { |l| FactoryGirl.create(:asset_report, lecture: l) }
        end
        let!(:extra_asset_reports) do
          lectures.map { |l| FactoryGirl.create(:asset_report, lecture: l) }
        end
        let(:enrollments) { asset_reports.map(&:enrollment).flatten }

        it "should return enrollments's asset reports" do
          subject.get_asset_reports_for(enrollments).should == asset_reports
        end

        it "should return a ActiveRecord::Relation" do
          subject.get_asset_reports_for(enrollments).should be_a \
            ActiveRecord::Relation
        end
      end
    end
  end
end
