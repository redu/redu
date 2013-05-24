# -*- encoding : utf-8 -*-
require "spec_helper"

module EnrollmentService
  describe Facade do
    subject { Facade.instance }
    let(:vis_adapter) { mock("VisAdapter") }
    let(:enrollment_service) { mock('EnrollmentEntityService') }
    let(:asset_report_service) { mock('AssetReportEntityService') }
    let(:subj) { FactoryGirl.create(:subject, space: nil) }
    let(:users) { FactoryGirl.create_list(:user, 3) }
    let(:user) { FactoryGirl.create(:user) }
    let(:subjects) { FactoryGirl.create_list(:subject, 3, space: nil) }

    before do
      mock_vis_adapter(vis_adapter)
      vis_adapter.stub(:notify_enrollment_creation)
      vis_adapter.stub(:notify_subject_finalized)
    end

    context "#create_enrollment" do
      before do
        mock_enrollment_service(enrollment_service)
      end

      it "should initalize EnrollmentEntityService with the correct arguments" do
        enrollment_service.stub(:create).and_return([])

        EnrollmentEntityService.should_receive(:new).
          with(subject: [subj]).and_return(enrollment_service)

        subject.create_enrollment([subj], [user])
      end

      it "should invoke EnrollmentEntityService#create with only users" do
        enrollment_service.should_receive(:create).
          with(users: users, role: nil).and_return([])
        subject.create_enrollment([subj], users)
      end

      it "should invoke EnrollmentEntityServie#create with the role passed" do
        role = Role[:environment_admin]
        enrollment_service.should_receive(:create).
          with(users: users, role: role).and_return([])

        subject.create_enrollment([subj], users, role: role)
      end

      context "with multiple subjects and users" do
        it "should invoke EnrollmentEntityService#create users and roles" do
          role = Role[:member]
          enrollment_service.should_receive(:create).
            with(users: users, role: role).and_return([])

          subject.create_enrollment(subjects, users, role: role)
        end
      end

      context "without args" do
        it "should invoke EnrollmentEntityService#create with nil" do
          enrollment_service.should_receive(:create).
            with(users: nil, role: nil).and_return([])
          subject.create_enrollment(subjects)
        end
      end

      context "VisAdapter" do
        let(:enrollments) do
          FactoryGirl.create_list(:enrollment, 2, subject: nil)
        end

        it "should invoke VisAdapter#notify_enrollment_creation with created" \
          " enrollments" do
          enrollment_service.stub(:create).and_return(enrollments)

          vis_adapter.should_receive(:notify_enrollment_creation).
            with(enrollments)

          subject.create_enrollment([subj], [user])
        end
      end

      context "UntiedAdapter" do
        let(:enrollments) do
          FactoryGirl.create_list(:enrollment, 2, subject: nil)
        end
        let(:untied_adapter) { mock('UntiedAdapter') }

        it "should invoke UntiedAdapter#notify_after_create" do
          subject.stub(:untied_adapter).and_return(untied_adapter)
          enrollment_service.stub(:create).and_return(enrollments)

          untied_adapter.should_receive(:notify_after_create).
            with(enrollments)

          subject.create_enrollment([subj], [user])
        end
      end
    end

    context "#create_asset_report" do
      let(:lectures) { subjects.map(&:lectures).flatten }

      before do
        mock_asset_report_service(asset_report_service)
        add_lecture_to(subjects)
      end

      context "with multiple lectures and users" do
        let(:enrollments) { Enrollment.where(subject_id: subjects) }

        it "should initalize AssetReportEntityService with the correct" \
          " arguments" do
          subject.create_enrollment(subjects, users)
          asset_report_service.stub(:create)

          AssetReportEntityService.should_receive(:new).
            with(lecture: lectures).and_return(asset_report_service)

          subject.create_asset_report(lectures: lectures,
                                      enrollments: enrollments)
        end

        it "should invoke AssetReportEntityService#create with the enrollments" do
          subject.create_enrollment(subjects, users)

          asset_report_service.should_receive(:create) do |args|
            args.map(&:user_id).should =~ users.map(&:id) * subjects.length
          end.and_return([])

          subject.create_asset_report(lectures: lectures,
                                      enrollments: enrollments)
        end
      end

      context "without users" do
        it "should invoke AssetReportEntityService#create without arguments" do
          asset_report_service.should_receive(:create).and_return([])
          subject.create_asset_report(lectures: lectures)
        end
      end
    end

    context "#destroy_enrollment" do
      let!(:enrollments) do
        FactoryGirl.create_list(:enrollment, 2, subject: nil)
      end
      let(:enrollments_arel) do
        Enrollment.limit(2)
      end

      before do
        mock_vis_adapter(vis_adapter)
        vis_adapter.stub(:notify_enrollment_removal)
        vis_adapter.stub(:notify_remove_subject_finalized)
        mock_enrollment_service(enrollment_service)
      end

      context "with multiple users and subjects" do
        it "should initialize EnrollmentEntityService with subjects" do
          enrollment_service.stub(:get_enrollments_for).
            and_return(enrollments_arel)
          enrollment_service.stub(:destroy)

          EnrollmentEntityService.should_receive(:new).
            with(subject: subjects)

          subject.destroy_enrollment(subjects, users)
        end

        it "should invoke EnrollmentEntityService#get_enrollments_for with" \
          " users" do
          enrollment_service.stub(:destroy)

          enrollment_service.should_receive(:get_enrollments_for).with(users).
            and_return(enrollments_arel)
          subject.destroy_enrollment(subjects, users)
        end

        it "should invoke EnrollmentEntityService#destroy with users" do
          enrollment_service.stub(:get_enrollments_for).
            and_return(enrollments_arel)

          enrollment_service.should_receive(:destroy).with(users)
          subject.destroy_enrollment(subjects, users)
        end
      end

      context "Adapters" do
        let(:untied_adapter) { mock('UntiedAdapter') }

        before do
          enrollment_service.stub(:destroy)
          enrollment_service.stub(:get_enrollments_for).
            and_return(enrollments_arel)
        end

        context "VisAdapter" do
          let!(:graduated_enrollments) do
            e = enrollments.last
            e.update_attributes(graduated: true)
            [e]
          end

          it "should invoke VisAdapter#notify_enrollment_removal with removed" \
            " enrollments" do
            vis_adapter.should_receive(:notify_enrollment_removal).
              with(enrollments)

            subject.destroy_enrollment(subjects, users)
          end

          it "should invoke VisAdapter#notify_remove_subject_finalized with" \
            " removed graduated enrollments" do
            vis_adapter.should_receive(:notify_remove_subject_finalized).
              with(graduated_enrollments)

            subject.destroy_enrollment(subjects, users)
          end
        end

        context "UntiedAdapter" do
          it "should invoke UntiedAdapter#notify_after_destroy" do
            subject.stub(:untied_adapter).and_return(untied_adapter)

            untied_adapter.should_receive(:notify_after_destroy).
              with(enrollments)

            subject.destroy_enrollment(subjects, users)
          end
        end
      end
    end

    context "#destroy_asset_report" do
      before do
        mock_vis_adapter(vis_adapter)
        vis_adapter.stub(:notify_enrollment_removal)
        vis_adapter.stub(:notify_remove_subject_finalized)
        mock_asset_report_service(asset_report_service)
      end

      context "with multiple users and subjects" do
        it "should initialize AssetReportEntityService with lectures" do
          add_lecture_to(subjects)
          subject.create_enrollment(subjects, users)
          asset_report_service.stub(:destroy)

          lectures = subjects.map(&:lectures).flatten
          AssetReportEntityService.should_receive(:new).with(lecture: \
                                                             lectures)
          subject.destroy_asset_report(lectures, users)
        end

        it "should invoke AssetReportEntityService#destroy with users'" \
           "enrollments" do
          subject.create_enrollment(subjects, users)
          enrollments = subjects.map(&:enrollments).flatten
          asset_report_service.should_receive(:destroy).with(enrollments)
          subject.destroy_asset_report(subjects, enrollments)
        end
      end
    end

    context "#update_grade" do
      let(:enrollments) { 3.times.map { mock_model Enrollment } }
      before do
        enrollment_service.stub(:update_grade)
        vis_adapter.stub(:notify_subject_finalized)
      end

      it "should initialize EnrollmentEntityService with the enrollments" do
        EnrollmentEntityService.should_receive(:new).
          with(enrollment: enrollments).and_return(enrollment_service)

        subject.update_grade(enrollments)
      end

      it "should call EnrollmentEntityService#update_grade" do
        mock_enrollment_service(enrollment_service)

        enrollment_service.should_receive(:update_grade)

        subject.update_grade(enrollments)
      end
    end

    def mock_enrollment_service(m)
      EnrollmentEntityService.stub(:new).and_return(m)
    end

    def mock_asset_report_service(m)
      AssetReportEntityService.stub(:new).and_return(m)
    end

    def mock_vis_adapter(m)
      subject.stub(:vis_adapter).and_return(m)
    end

    def add_lecture_to(subj)
      subjects = subj.respond_to?(:map) ? subj : [subj]

      subjects.each do |s|
        FactoryGirl.create(:lecture, owner: s.owner, subject: s)
      end
    end

    def set_space_to(subj)
      subjects = subj.respond_to?(:map) ? subj : [subj]

      subjects.each do |s|
        s.space = FactoryGirl.create(:space, owner: s.owner)
        s.save
      end
    end
  end
end
