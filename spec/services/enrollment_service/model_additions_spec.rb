require 'spec_helper'

module EnrollmentService
  describe Subject do
    subject { Factory(:subject,:space =>nil) }
    let(:user) { Factory(:user) }
    let(:vis_adapter) { mock("VisAdapter") }
    let(:create_enrollment_service) { mock('EnrollmentEntityService') }
    let(:asset_report_service) { mock('AssetReportEntityService') }

    context ".enroll" do
      before do
        mock_vis_adapter(vis_adapter)
        vis_adapter.stub(:notify_enrollment_creation)
      end

      it "responds to enroll" do
        should respond_to :enroll
      end

      context "with one user" do
        it "should initalize EnrollmentEntityService with the correct arguments" do
          create_enrollment_service.stub(:create)

          EnrollmentEntityService.should_receive(:new).
            with(:subject => [subject]).and_return(create_enrollment_service)

          Subject.enroll(subject, :users => [user])
        end

        it "should initalize AssetReportEntityService with the correct arguments" do
          add_lecture_to(subject)
          asset_report_service.stub(:create)

          AssetReportEntityService.should_receive(:new).
            with(:lecture => subject.lectures).and_return(asset_report_service)

          Subject.enroll(subject, :users => [user])
        end

        it "should invoke EnrollmentEntityService#create without role" do
          mock_enrollment_service(create_enrollment_service)

          create_enrollment_service.
            should_receive(:create).with([[user, Role[:member].to_s]])

          Subject.enroll(subject, :users => [user])
        end

        it "should invoke EnrollmentEntityServie#create with the role passed" do
          mock_enrollment_service(create_enrollment_service)

          create_enrollment_service.
            should_receive(:create).with([[user, Role[:environment_admin].to_s]])

          Subject.
            enroll([subject], :users => [user], :role => Role[:environment_admin])
        end

        it "should invoke AssetReportEntityService#create with the enrollments" do
          add_lecture_to(subject)
          mock_asset_report_service(asset_report_service)

          asset_report_service.should_receive(:create) do |args|
            args.first.should be_an_instance_of(Enrollment)
          end

          Subject.enroll(subject, :users => [user])
        end

        it "should return the enrollment" do
          Subject.enroll(subject, :users => [user]).
            should == [user.get_association_with(subject)]
        end
      end

      context "with multiple users" do
        let(:users) { FactoryGirl.create_list(:user, 3) }

        it "should invoke EnrollmentEntityService#create with users and roles" do
          mock_enrollment_service(create_enrollment_service)

          create_enrollment_service.
            should_receive(:create).with(users.map { |u| [u, Role[:member].to_s]})

          Subject.enroll(subject, :users => users)
        end

        it "should invoke AssetReportEntityService#create with enrollments" do
          add_lecture_to(subject)
          mock_asset_report_service(asset_report_service)

          asset_report_service.should_receive(:create) do |args|
            args.map(&:user_id).should =~ users.map(&:id)
          end

          Subject.enroll(subject, :users => users)
        end

        it "should return the enrollments" do
          Subject.enroll(subject, :users => users).
            should == users.map { |u| u.get_association_with subject }
        end
      end

      context "with no users" do
        let(:space) do
          Factory(:space, :owner => subject.owner, :course => nil)
        end

        before do
          Factory(:user_space_association, :user => user, :space => space)
          subject.space = space
          subject.save
        end

        it "should invoke EnrollmentEntityService#create without arguments" do
          mock_enrollment_service(create_enrollment_service)
          create_enrollment_service.should_receive(:create)
          Subject.enroll(subject)
        end

        it "should invoke AssetReportEntityService#create without arguments" do
          mock_asset_report_service(asset_report_service)
          asset_report_service.should_receive(:create)
          Subject.enroll(subject)
        end

        it "should return the enrollments" do
          Subject.enroll([subject]).
            should =~ space.users.map { |u| u.get_association_with(subject) }
        end
      end

      context "with multiple subjects and users" do
        let(:users) { FactoryGirl.create_list(:user, 3) }
        let(:subjects) { FactoryGirl.create_list(:subject, 3, :space => nil) }

        it "should initialize EnrollmentEntityService with the correct args" do
          create_enrollment_service.stub(:create)
          EnrollmentEntityService.should_receive(:new).
            with(:subject => subjects).and_return(create_enrollment_service)

          Subject.enroll(subjects, :users => users)
        end

        it "should initialize AssetReportEntityService with the correct args" do
          add_lecture_to(subjects)
          asset_report_service.stub(:create)
          lectures = subjects.map(&:lectures).flatten

          AssetReportEntityService.should_receive(:new).
            with(:lecture => lectures).and_return(asset_report_service)

          Subject.enroll(subjects, :users => users)
        end

        it "should invoke EnrollmentEntityService#create users and roles" do
          mock_enrollment_service(create_enrollment_service)
          users_and_roles = users.map { |u| [u, Role[:member]] }

          create_enrollment_service.should_receive(:create).with(users_and_roles)

          Subject.enroll(subjects, :users => users)
        end

        it "should invoke AssetReportEntityService#create with the enrollments" do
          add_lecture_to(subjects)
          mock_asset_report_service(asset_report_service)

          asset_report_service.should_receive(:create) do |args|
            args.map(&:user_id).should =~ users.map(&:id) * subjects.length
          end

          Subject.enroll(subjects, :users => users)
        end
      end
    end

    context "#enroll" do
      context "without users" do
        it "should delegate to .enroll with self" do
          Subject.should_receive(:enroll).with(subject, {})

          subject.enroll
        end
      end

      context "with multiple users" do
        let(:users) { FactoryGirl.build_list(:user, 3) }

        it "should delegate to .enroll with self and :users" do
          Subject.should_receive(:enroll).
            with(subject, :users => users, :role => Role[:member])

          subject.enroll(users)
        end

        it "should accept the :role" do
          Subject.should_receive(:enroll).
            with(subject, :users => users, :role => Role[:environment_admin])

          subject.enroll(users, :role => Role[:environment_admin])
        end
      end
    end

    context "#unenroll" do
      before do
        mock_vis_adapter(vis_adapter)
        vis_adapter.stub(:notify_enrollment_removal)
        vis_adapter.stub(:notify_graduated_enrollment_removal)
      end

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
      before do
        mock_vis_adapter(vis_adapter)
        vis_adapter.stub(:notify_enrollment_removal)
        vis_adapter.stub(:notify_graduated_enrollment_removal)
      end

      it "responds to unenroll" do
        Subject.should respond_to :unenroll
      end

      context "with one user and subject" do
        let(:enrollment) do
          Factory(:enrollment, :user => user, :subject => subject)
        end

        it "should initialize EnrollmentEntityService with subject" do
          create_enrollment_service.stub(:destroy)
          mock_enrollment_service(create_enrollment_service)

          EnrollmentEntityService.should_receive(:new).with(:subject => \
                                                            subject)
          Subject.unenroll(subject, user)
        end

        it "should initialize AssetReportEntityService with lecture" do
          add_lecture_to(subject)

          asset_report_service.stub(:destroy)
          mock_asset_report_service(asset_report_service)

          AssetReportEntityService.should_receive(:new).
            with(:lecture => subject.lectures)
          Subject.unenroll(subject, user)
        end

        it "should invoke EnrollmentEntityService#destroy with user" do
          mock_enrollment_service(create_enrollment_service)
          create_enrollment_service.should_receive(:destroy).with(user)
          Subject.unenroll(subject, user)
        end

        it "should invoke AssetReportEntityService#destroy with user's " \
          "enrollment" do
          mock_asset_report_service(asset_report_service)
          asset_report_service.should_receive(:destroy).with([enrollment])
          Subject.unenroll(subject, user)
        end
      end

      context "with multiple users and subjects" do
        let(:users) { FactoryGirl.create_list(:user, 3) }
        let(:subjects) do
          FactoryGirl.create_list(:subject, 3, :space => nil)
        end
        let(:enrollments) do
          subjects.map do |s|
            users.map do |user|
              Factory(:enrollment, :user => user, :subject => s)
            end.flatten
          end.flatten
        end

        it "should initialize EnrollmentEntityService with subjects" do
          mock_enrollment_service(create_enrollment_service)
          create_enrollment_service.stub(:destroy)

          EnrollmentEntityService.should_receive(:new).
            with(:subject => subjects)
          Subject.unenroll(subjects, users)
        end

        it "should initialize AssetReportEntityService with lectures" do
          add_lecture_to(subjects)

          mock_asset_report_service(asset_report_service)
          asset_report_service.stub(:destroy)

          lectures = subjects.map(&:lectures).flatten
          AssetReportEntityService.should_receive(:new).with(:lecture => \
                                                             lectures)
          Subject.unenroll(subjects, users)
        end

        it "should invoke EnrollmentEntityService#destroy with users" do
          mock_enrollment_service(create_enrollment_service)
          create_enrollment_service.should_receive(:destroy).with(users)
          Subject.unenroll(subjects, users)
        end

        it "should invoke AssetReportEntityService#destroy with users'" \
          "enrollments" do
          mock_asset_report_service(asset_report_service)
          asset_report_service.should_receive(:destroy).with(enrollments)
          Subject.unenroll(subjects, users)
        end
      end
    end

    context "VisAdapter notifications" do
      let(:subjects) do
        FactoryGirl.create_list(:subject, 3, :space => nil)
      end
      let(:users) { FactoryGirl.create_list(:user, 3) }

      before do
        set_space_to(subjects)
      end

      context ".enroll" do
        it "should invoke VisAdapter for created enrollments" do
          mock_vis_adapter(vis_adapter)
          vis_adapter.should_receive(:notify_enrollment_creation) do |args|
            args.first.should be_an_instance_of(Enrollment)
          end

          Subject.enroll(subjects, :users => users)
        end
      end

      context ".unenroll" do
        let(:enrollments) do
          subjects.map do |s|
            users.map do |user|
              Factory(:enrollment, :user => user, :subject => s)
            end.flatten
          end.flatten
        end

        it "should invoke VisAdapter for removed enrollments" do
          vis_adapter.stub(:notify_graduated_enrollment_removal)
          mock_vis_adapter(vis_adapter)

          vis_adapter.should_receive(:notify_enrollment_removal).
            with(enrollments)
          Subject.unenroll(subjects, users)
        end

        it "should invoke VisAdapter for removed graduated enrollments" do
          graduated_enrollments = enrollments[0..2]
          graduated_enrollments.each do |e|
            e.update_attribute(:graduated, true)
          end

          vis_adapter.stub(:notify_enrollment_removal)
          mock_vis_adapter(vis_adapter)

          vis_adapter.should_receive(:notify_graduated_enrollment_removal).
            with(graduated_enrollments)
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

    def mock_vis_adapter(m)
      VisAdapter.stub(:new).and_return(m)
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
        s.space = Factory(:space)
        s.save
      end
    end
  end
end
