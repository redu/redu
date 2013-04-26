require "spec_helper"

module EnrollmentService
  describe Facade do
    subject { Facade.instance }
    let(:vis_adapter) { mock("VisAdapter") }
    let(:enrollment_service) { mock('EnrollmentEntityService') }
    let(:asset_report_service) { mock('AssetReportEntityService') }
    let(:subj) { Factory(:subject, :space => nil) }
    let(:users) { FactoryGirl.create_list(:user, 3) }
    let(:user) { Factory(:user) }
    let(:subjects) { FactoryGirl.create_list(:subject, 3, :space => nil) }

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
        enrollment_service.stub(:create)

        EnrollmentEntityService.should_receive(:new).
          with(:subject => [subj]).and_return(enrollment_service)

        subject.create_enrollment([subj], [user])
      end

      it "should invoke EnrollmentEntityService#create with only users" do
        enrollment_service.should_receive(:create).with(:users => users,
                                                        :role => nil)
        subject.create_enrollment([subj], users)
      end

      it "should invoke EnrollmentEntityServie#create with the role passed" do
        role = Role[:environment_admin]
        enrollment_service.should_receive(:create).with(:users => users,
                                                        :role => role)
        subject.create_enrollment([subj], users, :role => role)
      end

      context "with multiple subjects and users" do
        it "should invoke EnrollmentEntityService#create users and roles" do
          role = Role[:member]
          enrollment_service.should_receive(:create).with(:users => users,
                                                          :role => role)
          subject.create_enrollment(subjects, users, :role => role)
        end
      end

      context "without args" do
        it "should invoke EnrollmentEntityService#create with nil" do
          enrollment_service.should_receive(:create).with(:users => nil,
                                                          :role => nil)
          subject.create_enrollment(subjects)
        end
      end
    end

    context "#create_asset_report" do
      before do
        mock_asset_report_service(asset_report_service)
      end

      context "with multiple subjects and users" do
        before do
          add_lecture_to(subjects)
        end

        it "should initalize AssetReportEntityService with the correct arguments" do
          subject.create_enrollment(subjects, users)
          asset_report_service.stub(:create)

          lectures = subjects.map(&:lectures).flatten
          AssetReportEntityService.should_receive(:new).
            with(:lecture => lectures).and_return(asset_report_service)

          subject.create_asset_report(:subjects => subjects, :users => users)
        end

        it "should invoke AssetReportEntityService#create with the enrollments" do
          subject.create_enrollment(subjects, users)

          asset_report_service.should_receive(:create) do |args|
            args.map(&:user_id).should =~ users.map(&:id) * subjects.length
          end

          subject.create_asset_report(:subjects => subjects, :users => users)
        end
      end

      context "with multiple lectures and users" do
        let(:lectures) { lectures = subjects.map(&:lectures).flatten }

        before do
          add_lecture_to(subjects)
        end

        it "should initalize AssetReportEntityService with the correct arguments" do
          subject.create_enrollment(subjects, users)
          asset_report_service.stub(:create)

          AssetReportEntityService.should_receive(:new).
            with(:lecture => lectures).and_return(asset_report_service)

          subject.create_asset_report(:lectures => lectures, :users => users)
        end

        it "should invoke AssetReportEntityService#create with the enrollments" do
          subject.create_enrollment(subjects, users)

          asset_report_service.should_receive(:create) do |args|
            args.map(&:user_id).should =~ users.map(&:id) * subjects.length
          end

          subject.create_asset_report(:lectures => lectures, :users => users)
        end
      end

      context "without users" do
        it "should invoke AssetReportEntityService#create without arguments" do
          asset_report_service.should_receive(:create)
          subject.create_asset_report(:subjects => subjects)
        end
      end
    end

    context "#destroy_enrollment" do
      before do
        mock_vis_adapter(vis_adapter)
        vis_adapter.stub(:notify_enrollment_removal)
        vis_adapter.stub(:notify_remove_subject_finalized)
        mock_asset_report_service(asset_report_service)
      end

      context "with multiple users and subjects" do
        it "should initialize EnrollmentEntityService with subjects" do
          enrollment_service.stub(:destroy)
          mock_enrollment_service(enrollment_service)

          EnrollmentEntityService.should_receive(:new).
            with(:subject => subjects)

          subject.destroy_enrollment(subjects, users)
        end

        it "should invoke EnrollmentEntityService#destroy with users" do
          mock_enrollment_service(enrollment_service)
          enrollment_service.should_receive(:destroy).with(users)
          subject.destroy_enrollment(subjects, users)
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
          AssetReportEntityService.should_receive(:new).
            with(:lecture => lectures)

          subject.destroy_asset_report(subjects, users)
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

    context "VisAdapter" do
      before do
        mock_vis_adapter(vis_adapter)
        set_space_to(subjects)
      end

      context "#notify_enrollment_creation" do
        it "should invoke VisAdapter for created enrollments" do
          subject.create_enrollment(subjects, users)
          enrollments = subjects.map(&:enrollments).flatten

          vis_adapter.should_receive(:notify_enrollment_creation) do |args|
            args.first.should be_an_instance_of(Enrollment)
          end

          subject.notify_enrollment_creation(enrollments)
        end
      end

      context "#notify_enrollment_removal" do
        let(:enrollments) do
          subject.create_enrollment(subjects, users)
          subjects.map(&:enrollments).flatten
        end

        it "should invoke VisAdapter for removed enrollments" do
          vis_adapter.stub(:notify_remove_subject_finalized)

          vis_adapter.should_receive(:notify_enrollment_removal).
            with(enrollments)

          subject.notify_enrollment_removal(enrollments)
        end

        it "should invoke VisAdapter for removed graduated enrollments" do
          vis_adapter.stub(:notify_enrollment_removal)
          graduated_enrollments = enrollments[0..2]
          graduated_enrollments.each do |e|
            e.update_attribute(:graduated, true)
          end

          vis_adapter.should_receive(:notify_remove_subject_finalized).
            with(graduated_enrollments)

          subject.notify_enrollment_removal(enrollments)
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
          with(:enrollment => enrollments).and_return(enrollment_service)

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
        Factory(:lecture, :owner => s.owner, :subject => s)
      end
    end

    def set_space_to(subj)
      subjects = subj.respond_to?(:map) ? subj : [subj]

      subjects.each do |s|
        s.space = Factory(:space, :owner => s.owner)
        s.save
      end
    end
  end
end
