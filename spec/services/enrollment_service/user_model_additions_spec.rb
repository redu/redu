# -*- enconding : utf-8 -*-
require 'spec_helper'

module EnrollmentService
  describe User do
    subject { FactoryBot.create(:user) }
    let(:facade) { mock(Facade) }

    describe "before_destroy" do
      it "should invoke User#destroy_asset_reports" do
        subject.should_receive(:destroy_asset_reports).with(no_args())
        subject.destroy
      end

      it "should invoke User#destroy_enrollments" do
        subject.should_receive(:destroy_enrollments).with(no_args())
        subject.destroy
      end
    end

    describe "private destroy methods" do
      let!(:enrollments) do
        FactoryBot.create_list(:enrollment, 2, user: subject)
      end

      before do
        mock_facade(facade)
      end

      describe "#destroy_asset_reports" do
        let(:lectures) do
          enrollments.map do |e|
            FactoryBot.create(:lecture, subject: e.subject)
          end
        end

        it "should invoke Facade#destroy_asset_report with lectures and" \
          " enrollments" do
          facade.should_receive(:destroy_asset_report).with(lectures, enrollments)
          subject.send(:destroy_asset_reports)
        end
      end

      describe "#destroy_enrollments" do
        let(:subjects) { enrollments.map(&:subject) }

        it "should invoke Facade#destroy_enrollment with subjects and user" do
          facade.should_receive(:destroy_enrollment).with(subjects, subject)
          subject.send(:destroy_enrollments)
        end
      end
    end

    def mock_facade(m)
      Facade.stub(:instance).and_return(m)
    end
  end
end
