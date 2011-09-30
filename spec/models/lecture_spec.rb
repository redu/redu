require 'spec_helper'

describe Lecture do
  before do
    environment = Factory(:environment)
    course = Factory(:course, :owner => environment.owner,
                     :environment => environment)
    @space = Factory(:space, :owner => environment.owner,
                     :course => course)
    @user = Factory(:user)
    course.join(@user)
    @sub = Factory(:subject, :owner => @user, :space => @space,
                   :finalized => true)
    @sub.create_enrollment_associations
  end

  subject { Factory(:lecture, :subject => @sub,
                    :owner => @sub.owner) }

  it { should belong_to :owner }
  it { should belong_to(:lectureable).dependent(:destroy) }

  it { should have_many(:favorites).dependent(:destroy) }

  it { should have_many(:logs) }
  it { should have_many(:statuses).dependent(:destroy) }

  it { should belong_to :subject }

  it { should validate_presence_of :name }
  # Descrição não está sendo utilizada
  xit { should validate_presence_of :description }
  #FIXME Problema de tradução
  xit { should ensure_length_of(:description).is_at_least(30).is_at_most(200)}
  it { should validate_presence_of :lectureable }

  it { should_not allow_mass_assignment_of :owner }
  it { should_not allow_mass_assignment_of :published }
  it { should_not allow_mass_assignment_of :view_count }
  it { should_not allow_mass_assignment_of :removed }
  it { should_not allow_mass_assignment_of :is_clone }

  it "responds to mark_as_done_for!" do
    should respond_to :mark_as_done_for!
  end

  context "callbacks" do
    context "creates a AssertReport between the StudentProfile and the Lecture after create" do
      it "when the owner is the subject owner" do
        subject.asset_reports.of_user(subject.owner).should_not be_empty
      end

      it "when the owner is an environment_admin" do
        # First lecture is created
        subject.should_not be_new_record

        another_admin = Factory(:user)
        @space.course.spaces.reload
        @space.subjects.reload
        @space.course.join another_admin
        @space.course.environment.change_role(another_admin,
                                              Role[:environment_admin])

        lecture = Factory(:lecture, :subject => @sub,
                          :owner => another_admin)

        lecture.asset_reports.should_not be_empty
        lecture.asset_reports.count.should == @sub.members.count
        @sub.members.each do |member|
          lecture.asset_reports.of_user(member).should_not be_empty
        end
      end
    end
  end

  context "finders" do
    it "retrieves unpublished lectures" do
      lectures = (1..3).collect { Factory(:lecture, :subject => @sub,
                                          :published => false) }
      subject.published = 1
      lectures[2].published = 1
      subject.save
      lectures[2].save

      Lecture.unpublished.should == [lectures[0], lectures[1]]
    end

    it "retrieves published lectures" do
      lectures = (1..3).collect { Factory(:lecture,
                                          :subject => @sub,
                                          :published => false) }
      subject.published = 1
      lectures[2].published = 1
      subject.save
      lectures[2].save

      Lecture.published.should == [lectures[2], subject]
    end

    it "retrieves lectures that are seminars" do
      pending "Need seminar Factory" do
        seminars = (1..2).collect { Factory(:lecture,:subject => @sub,
                                            :lectureable => Factory(:seminar)) }
        Factory(:lecture, :subject => @sub)

        Lecture.seminars.should == seminars
      end
    end

    #FIXME não fazer teste com chamada a APIs externas
    xit "retrieves lectures that are pages" do
        page = Factory(:lecture, :subject => @sub)
        documents = (1..2).collect {
          Factory(:lecture, :subject => @sub,
                  :lectureable => Factory(:document)) }
        Lecture.pages.should == [page]
    end

    xit "retrieves lectures that are documents" do
        page = Factory(:lecture, :subject => @sub)
        documents = (1..2).collect {
          Factory(:lecture, :subject => @sub,
                  :lectureable => Factory(:document)) }

        Lecture.documents.should == documents
    end

    it "retrieves a specified limited number of lectures" do
      lectures = (1..10).collect { Factory(:lecture, :subject => @sub) }
      Lecture.limited(5).should have(5).items
    end

    it "retrieves lectures related to a specified lecture" do
      lecture = Factory(:lecture, :subject => @sub, :name => "Item com nome")
      lecture2 = Factory(:lecture, :subject => @sub, :name => "Item")

      Lecture.related_to(lecture2).should == [lecture]
    end
  end

  context "being attended" do
    context "when done" do
      it "mark the current lecture as done" do
        subject_owner = Factory(:user)
        space = Factory(:space)
        space.course.join subject_owner
        subject1 = Factory(:subject, :owner => subject_owner,
                           :space => space)
        lectures = (1..3).collect { Factory(:lecture, :subject => subject1) }

        user = Factory(:user)
        subject1.enroll user

        lectures[0].mark_as_done_for!(user, true)
        lectures[0].asset_reports.of_user(user).last.
          should be_done
      end
    end

    context "when undone" do
      it "mark the current lecture as undone" do
        subject_owner = Factory(:user)
        space = Factory(:space)
        space.course.join subject_owner
        subject1 = Factory(:subject, :owner => subject_owner,
                           :space => space)
        lectures = (1..3).collect { Factory(:lecture, :subject => subject1) }

        user = Factory(:user)
        subject1.enroll user

        lectures[0].asset_reports.of_user(user).last.done = true
        lectures[0].mark_as_done_for!(user, false)
        lectures[0].asset_reports.of_user(user).last.
          should_not be_done
      end
    end
  end

  it "generates a permalink" do
    Redu::Application.config.url.should_not be_nil
    subject.permalink.should include(subject.id.to_s)
    subject.permalink.should include(subject.name.parameterize)
  end

  it "generates a clone of itself" do
    subject_owner = Factory(:user)
    space = Factory(:space)
    space.course.join subject_owner
    subject1 = Factory(:subject, :owner => subject_owner,
                       :space => space)

    new_lecture = subject.clone_for_subject!(subject1.id)
    new_lecture.should_not == subject
    new_lecture.should be_is_clone
    new_lecture.subject.should == subject1
  end
  context "destroy" do
    before do
      @lec = Factory(:lecture, :subject => @sub,
                     :owner => @sub.owner)
    end

    #FIXME encontrar um jeito melhor de se testar o refresh_students_profiles
    it "should update all students profiles" do
      assets = AssetReport.all(:conditions => {
                                       :subject_id => subject.subject.id,
                                       :lecture_id => @lec.id})
      assets.each do |asset|
        asset.done = 1
        asset.save
      end
      @lec.refresh_students_profiles
      grade = StudentProfile.sum('grade', :conditions =>
                                           {:subject_id => subject.subject.id})
      grade.should == 100
      @lec.destroy
      @lec.refresh_students_profiles
      grade = StudentProfile.sum('grade', :conditions =>
                                           {:subject_id => subject.subject.id})
      grade.should == 0
    end
  end
end
