require 'spec_helper'

module EnrollmentService
  describe Subject do
    subject { Factory(:subject, :space => nil) }
    let(:user) { Factory(:user) }
    let(:vis_client) { mock('VisClient') }
    let(:create_enrollment_service) { mock('CreateEnrollment') }
    let(:asset_report_service) { mock('AssetReportService') }

    before do
      vis_client.stub(:notify_delayed)
      Subject.vis_client = vis_client
    end

    context "#enroll" do
      it "responds to enroll" do
        should respond_to :enroll
      end

      context "with one user" do
        it "should invoke CreateEnrollmentService" do
          mock_enrollment_service(create_enrollment_service)

          create_enrollment_service.
            should_receive(:create).with([[user, Role[:member].to_s]])

          subject.enroll(user)
        end

        it "should invoke AssetReportService" do
          subject.lectures << Factory(:lecture, :owner => subject.owner)

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

        it "should invoke CreateEnrollmentService" do
          mock_enrollment_service(create_enrollment_service)

          create_enrollment_service.
            should_receive(:create).with(users.map { |u| [u, Role[:member].to_s]})

          subject.enroll(users)
        end

        it "should invoke AssetReportService" do
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
          Factory(:space, :owner => subject.owner)
        end

        before do
          space.users << user
          subject.space = space
          subject.save
        end

        xit "should invoke CreateEnrollmentService#create without arguments" do
          mock_enrollment_service(create_enrollment_service)
          create_enrollment_service.should_receive(:create)

          subject.enroll
        end

        xit "should invoke AssetReportService" do
          subject.lectures << Factory(:lecture, :owner => subject.owner)

          AssetReportService.stub(:new).and_return(asset_report_service)

          asset_report_service.should_receive(:create) do |args|
            args.map(&:user_id).should =~ space.users.map(&:id)
          end
        end

        it "should return the enrollments"
      end
    end

    it "responds to unenroll" do
      should respond_to :unenroll
    end

    it "responds to enrolled?" do
      should respond_to :enrolled?
    end

    def mock_enrollment_service(m)
      CreateEnrollment.stub(:new).and_return(m)
    end

    def mock_asset_report_service(m)
      AssetReportService.stub(:new).and_return(m)
    end
  end
end
