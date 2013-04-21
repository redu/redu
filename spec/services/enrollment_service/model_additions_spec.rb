require 'spec_helper'

module EnrollmentService
  describe Subject do
    subject { Factory(:subject, :space => nil) }
    let(:user) { Factory(:user) }
    let(:vis_client) { mock('VisClient') }
    let(:create_enrollment_service) { mock('EnrollmentEntityService') }
    let(:asset_report_service) { mock('AssetReportEntityService') }

    before do
      vis_client.stub(:notify_delayed)
      Subject.vis_client = vis_client
    end

    context "#enroll" do
      it "responds to enroll" do
        should respond_to :enroll
      end

      context "with one user" do
        it "should initalize EnrollmentEntityService with the correct arguments" do
          create_enrollment_service.stub(:create)

          EnrollmentEntityService.should_receive(:new).
            with(:subject => [subject]).and_return(create_enrollment_service)

          subject.enroll(user)
        end

        it "should initalize AssetReportEntityService with the correct arguments" do
          add_lecture_to(subject)
          asset_report_service.stub(:create)

          AssetReportEntityService.should_receive(:new).
            with(:lecture => subject.lectures).and_return(asset_report_service)

          subject.enroll(user)
        end

        it "should invoke EnrollmentEntityService" do
          mock_enrollment_service(create_enrollment_service)

          create_enrollment_service.
            should_receive(:create).with([[user, Role[:member].to_s]])

          subject.enroll(user)
        end

        it "should invoke EnrollmentEntityServie#create with the role passed" do
          mock_enrollment_service(create_enrollment_service)

          create_enrollment_service.
            should_receive(:create).with([[user, Role[:environment_admin].to_s]])

          subject.enroll(user, :role => Role[:environment_admin])
        end

        it "should invoke AssetReportEntityService" do
          add_lecture_to(subject)
          mock_asset_report_service(asset_report_service)

          asset_report_service.should_receive(:create) do |args|
            args.first.should be_an_instance_of(Enrollment)
          end

          subject.enroll(user)
        end

        it "should return the enrollment" do
          subject.enroll(user).should == [user.get_association_with(subject)]
        end
      end

      context "with multiple users" do
        let(:users) { FactoryGirl.create_list(:user, 3) }

        it "should invoke EnrollmentEntityService#create with users and roles" do
          mock_enrollment_service(create_enrollment_service)

          create_enrollment_service.
            should_receive(:create).with(users.map { |u| [u, Role[:member].to_s]})

          subject.enroll(users)
        end

        it "should invoke AssetReportEntityService#create with enrollments" do
          subject.lectures << Factory(:lecture, :owner => subject.owner)

          mock_asset_report_service(asset_report_service)

          asset_report_service.should_receive(:create) do |args|
            args.map(&:user_id).should =~ users.map(&:id)
          end

          subject.enroll(users)
        end

        it "should return the enrollments" do
          subject.enroll(users).
            should == users.map { |u| u.get_association_with subject }
        end
      end

      context "with no users" do
        let(:space) do
          Factory(:space, :owner => subject.owner, :course => nil)
        end

        before do
          space.user_space_associations << \
            Factory(:user_space_association, :user => user, :space => space)
          subject.space = space
          subject.save
        end

        it "should invoke EnrollmentEntityService#create without arguments" do
          mock_enrollment_service(create_enrollment_service)
          create_enrollment_service.should_receive(:create)
          subject.enroll
        end

        it "should invoke AssetReportEntityService#create without arguments" do
          mock_asset_report_service(asset_report_service)
          asset_report_service.should_receive(:create)
          subject.enroll
        end

        it "should return the enrollments" do
          subject.enroll.should =~ space.users.map { |u| u.get_association_with(subject) }
        end
      end
    end

    context "#unenroll" do
      context "with one user" do
        it "should invoke .unenroll with self and user" do
          Subject.should_receive(:unenroll).with([subject], user)
          subject.unenroll(user)
        end
      end

      context "with multiple users" do
        let(:users) { FactoryGirl.create_list(:user, 3) }

        it "should invoke .unenroll with self and users" do
          Subject.should_receive(:unenroll).with([subject], users)
          subject.unenroll(users)
        end
      end
    end

    context ".unenroll" do
      it "responds to unenroll" do
        Subject.should respond_to :unenroll
      end

      context "with one user and subject" do
        let(:enrollment) do
          Factory(:enrollment, :user => user, :subject => subject)
        end

        it "should instantiate EnrollmentEntityService with subject" do
          create_enrollment_service.stub(:destroy)
          mock_enrollment_service(create_enrollment_service)

          EnrollmentEntityService.should_receive(:new).with(:subjects => \
                                                            subject)
          Subject.unenroll(subject, user)
        end

        it "should instantiate AssetReportEntityService with lecture" do
          add_lecture_to(subject)

          asset_report_service.stub(:destroy)
          mock_asset_report_service(asset_report_service)

          AssetReportEntityService.should_receive(:new).
            with(:lectures => subject.lectures)
          Subject.unenroll(subject, user)
        end

        it "should invoke EnrollmentEntityService with user" do
          mock_enrollment_service(create_enrollment_service)
          create_enrollment_service.should_receive(:destroy).with(user)
          Subject.unenroll(subject, user)
        end

        it "should invoke AssetReportEntityService with user's enrollment" do
          mock_asset_report_service(asset_report_service)
          asset_report_service.should_receive(:destroy).with([enrollment])
          Subject.unenroll(subject, user)
        end
      end

      context "with multiple users and subjects" do
        let(:users) { FactoryGirl.create_list(:user, 3) }
        let(:subjects) do
          FactoryGirl.create_list(:complete_subject, 3, :space => nil)
        end
        let(:enrollments) do
          subjects.map do |subj|
            users.map do |user|
              Factory(:enrollment, :user => user, :subject => subj)
            end.flatten
          end.flatten
        end

        it "should instantiate EnrollmentEntityService with subjects" do
          mock_enrollment_service(create_enrollment_service)
          create_enrollment_service.stub(:destroy)

          EnrollmentEntityService.should_receive(:new).
            with(:subjects => subjects)
          Subject.unenroll(subjects, users)
        end

        it "should instantiate AssetReportEntityService with lectures" do
          add_lecture_to(subjects)

          mock_asset_report_service(asset_report_service)
          asset_report_service.stub(:destroy)

          lectures = subjects.map(&:lectures).flatten
          AssetReportEntityService.should_receive(:new).with(:lectures => \
                                                             lectures)
          Subject.unenroll(subjects, users)
        end

        it "should invoke EnrollmentEntityService with users" do
          mock_enrollment_service(create_enrollment_service)
          create_enrollment_service.should_receive(:destroy).with(users)
          Subject.unenroll(subjects, users)
        end

        it "should invoke AssetReportEntityService with users' enrollments" do
          mock_asset_report_service(asset_report_service)
          enrollments_id_only = Enrollment.select("id").
            find(enrollments.map(&:id))

          asset_report_service.should_receive(:destroy) do |args|
            args =~ enrollments_id_only
          end

          Subject.unenroll(subjects, users)
        end
      end
    end

    it "responds to enrolled?" do
      should respond_to :enrolled?
    end

    def mock_enrollment_service(m)
      EnrollmentEntityService.stub(:new).and_return(m)
    end

    def mock_asset_report_service(m)
      AssetReportEntityService.stub(:new).and_return(m)
    end

    def add_lecture_to(subj)
      subjects = subj.respond_to?(:map) ? subj : [subj]

      subjects.each do |s|
        s.lectures << \
          Factory(:lecture, :owner => s.owner, :subject => s)
      end
    end
  end
end
