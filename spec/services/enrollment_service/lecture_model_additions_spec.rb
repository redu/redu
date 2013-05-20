# -*- encoding : utf-8 -*-
require 'spec_helper'

module EnrollmentService
  describe Lecture do
    subject { Factory(:lecture, :subject => nil) }
    let(:facade) { mock("Facade") }

    context "#create_asset_report" do
      before do
        add_subject_to(subject)
      end

      let(:enrollments) do
        FactoryGirl.create_list(:enrollment, 2, :subject => subject.subject)
      end

      it "should invoke Facade#create_asset_report with self" do
        facade.stub(:update_grade)
        mock_facade(facade)
        facade.should_receive(:create_asset_report).
          with(:lectures => [subject], :enrollments => [])
        subject.create_asset_report
      end

      it "should invoke Facade#update_grade with lecture's subject" \
        " enrollments" do
        facade.stub(:create_asset_report)

        mock_facade(facade)
        facade.should_receive(:update_grade).with(enrollments)
        subject.create_asset_report
      end
    end

    def mock_facade(m)
      Facade.stub(:instance).and_return(m)
    end

    def add_subject_to(lecture)
      lectures = lecture.respond_to?(:map) ? lecture : [lecture]
      lectures.each do |l|
        l.subject = Factory(:subject, :space => nil)
        l.save
      end
    end
  end
end
