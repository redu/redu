# -*- encoding : utf-8 -*-
require 'spec_helper'

module EnrollmentService
  describe GradeCalculator do
    context "#calculate_grade" do
      let(:enrollment) { FactoryGirl.create(:enrollment, :subject => nil) }
      let(:asset_reports) do
        FactoryGirl.create_list(:asset_report, 3, :enrollment => enrollment)
      end
      subject { GradeCalculator.new([enrollment]) }

      context "when all asset reports are done" do
        before { asset_reports.map { |ar| ar.update_attribute(:done, true) } }

        it "should set graduated to true" do
          _, _, graduated  = subject.calculate_grade.first
          graduated.should be_true
        end

        it "should set grade to 100" do
          _, grade, _ = subject.calculate_grade.first
          grade.should == 100
        end
      end

      context "when the enrollment have no asset reports" do
        before { enrollment.update_attribute(:graduated, true) }

        it "should set grade to 0" do
          _, grade, _ = subject.calculate_grade.first
          grade.should == 0
        end

        it "should set graduated to false" do
          _, _, graduated  = subject.calculate_grade.first
          graduated.should be_false
        end
      end

      context "when part 1/3 of the asset reports are done" do
        before do
          asset_reports.each_with_index do |as, index|
            as.update_attribute(:done, true) if index % 2 == 0
          end
        end

        it "should set graduated to false" do
          _, _, graduated  = subject.calculate_grade.first
          graduated.should be_false
        end

        it "should set grade to 66.66" do
          _, grade, _ = subject.calculate_grade.first
          grade.should be_within(0.1).of(66.66)
        end
      end
    end
  end
end
