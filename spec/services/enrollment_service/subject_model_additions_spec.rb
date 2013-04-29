require 'spec_helper'

module EnrollmentService
  describe Subject do
    subject { Factory(:subject, :space => nil) }
    let(:user) { Factory(:user) }
    let(:facade) { mock("Facade") }
    let(:lectures) do
      subjects.each { |s| FactoryGirl.create(:lecture, :subject => s) }
      Lecture.where(:subject_id => subjects)
    end

    context ".enroll" do
      let!(:subjects) { FactoryGirl.create_list(:subject, 3) }
      let(:users) { FactoryGirl.create_list(:user, 3) }
      let!(:enrollments) { FactoryGirl.create_list(:enrollment, 2) }

      before { mock_facade(facade) }

      it "responds to enroll" do
        should respond_to :enroll
      end

      it "should invoke Facade#create_enrollment with correct arguments" do
        facade.stub(:create_asset_report)
        facade.stub(:notify_enrollment_creation)
        facade.stub(:update_grade)

        facade.should_receive(:create_enrollment).with(subjects, users,
                                                       :role => Role[:member])
        Subject.enroll(subjects, :users => users)
      end

      it "should invoke Facade#create_asset_report with correct arguments" do
        facade.stub(:create_enrollment) { enrollments }
        facade.stub(:notify_enrollment_creation)
        facade.stub(:update_grade)

        lectures
        facade.should_receive(:create_asset_report) do |args|
          args[:lectures].should =~ lectures
          args[:enrollments].should =~ enrollments
        end

        Subject.enroll(subjects, :users => users)
      end

      it "should invoke Facade#update_grade" do
        facade.stub(:create_enrollment)
        facade.stub(:create_asset_report)
        facade.stub(:notify_enrollment_creation)

        facade.should_receive(:update_grade)

        Subject.enroll(subjects, :users => users)
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
      let(:users) { FactoryGirl.create_list(:user, 3) }

      it "should invoke .unenroll with [self] and users" do
        Subject.should_receive(:unenroll).with([subject], users)
        subject.unenroll(users)
      end
    end

    context ".unenroll" do
      it "responds to unenroll" do
        Subject.should respond_to :unenroll
      end

      context do
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

        it "should invoke Facede#destroy_asset_report with correct arguments" do
          facade.stub(:notify_enrollment_removal)
          facade.stub(:destroy_enrollment)
          mock_facade(facade)

          facade.should_receive(:destroy_asset_report).with(lectures,
                                                            enrollments)
          Subject.unenroll(subjects, users)
        end

        it "should invoke Facede#destroy_enrollment with correct arguments" do
          facade.stub(:destroy_asset_report)
          facade.stub(:notify_enrollment_removal)
          mock_facade(facade)

          facade.should_receive(:destroy_enrollment).with(subjects, users)
          Subject.unenroll(subjects, users)
        end
      end
    end

    it "responds to enrolled?" do
      should respond_to :enrolled?
    end

    def mock_facade(m)
      Facade.stub(:instance).and_return(m)
    end
  end
end
