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
  it { should accept_nested_attributes_for :lectureable }

  it { should validate_presence_of :name }
  it { should validate_presence_of :lectureable }

  it { should_not allow_mass_assignment_of :owner }
  it { should_not allow_mass_assignment_of :view_count }
  it { should_not allow_mass_assignment_of :is_clone }

  it "responds to mark_as_done_for!" do
    should respond_to :mark_as_done_for!
  end

  it "responds to done?" do
    should respond_to :done?
  end

  it "responds to recent?" do
    should respond_to :recent?
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

  context "#create_asset_report" do
    let(:environment) { Factory.create(:complete_environment) }
    let(:user) { environment.owner }
    let(:course) { environment.courses.first }
    let(:space) { course.spaces.first }
    let(:sub) do
      Factory(:subject, :owner => user, :space => space, :finalized => true)
    end
    let(:subject) do
      Factory(:lecture, :subject => sub, :owner => user)
    end

    before do
      sub.create_enrollment_associations
      AssetReport.stub(:import)
    end

    context "with no arguments" do
      it "should create AssetReports with Subject's enrollments and Lecture" do
        args = { :subject => sub, :enrollment => sub.enrollments.first,
                 :lecture => subject }
        AssetReport.should_receive(:new).with(args)
        subject.create_asset_report
      end
    end

    context "passing a enrollment as argument" do
      it "should create AssetReport with enrollment passed" do
        enrollment = sub.enroll(Factory.create(:user))
        args = { :subject => sub, :enrollment => enrollment, :lecture => subject }
        AssetReport.should_receive(:new).with(args)
        subject.create_asset_report(:enrollments => [enrollment])
      end
    end

    it "should invoke Enrollment#update_grade!" do
      sub.enrollments.map { |e| e.should_receive(:update_grade!) }
      subject.create_asset_report
    end

    it "should batch insert AssetReports (AssetReport.import)" do
      AssetReport.should_receive(:import)
      subject.create_asset_report
    end
  end

  context "finders" do
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

    it "retrieves recent lectures (created until 1 week ago)" do
      lectures = (1..3).collect { |i| Factory(:lecture,
                                              :created_at => (i*3).day.ago) }
      Lecture.recent.should == lectures[0..1]
    end

    it "retrieves all editables exercises" do
      exercise1 = Factory(:exercise)
      lecture1 = Factory(:lecture, :subject => @sub,
                          :name => "Exercicio 1", :lectureable => exercise1)
      exercise2 = Factory(:exercise)
      lecture2 = Factory(:lecture, :subject => @sub,
                          :name => "Exercicio 2", :lectureable => exercise2)
      result = Factory(:result, :exercise => exercise1)

      Lecture.exercises_editables.should == [lecture2]
    end

    it "retrieve lectures in the specified subjects" do
      subject.reload
      lecture2 = Factory(:lecture, :subject => @sub, :owner => @user)
      sub2 = Factory(:subject)
      lecture3 = Factory(:lecture, :subject => sub2, :owner => @user)

      @user.lectures.by_subjects(@sub.id).to_set.should eq([subject, lecture2].to_set)
    end

    it "retrieves lectures by day" do
      subj = Factory(:subject)
      lec1 = Factory(:lecture, :subject => subj,
                     :created_at => "2012-02-14".to_date)
      lec2 = Factory(:lecture, :subject => subj,
                     :created_at => "2012-02-16".to_date)
      lectures = Lecture.by_subjects(subj.id)

      lectures.by_day("2012-02-14".to_date).should eq([lec1])
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

  context "when generating a clone of itself" do
    before do
      subject_owner = Factory(:user)
      space = Factory(:space)
      space.course.join subject_owner
      @new_subject = Factory(:subject, :owner => subject_owner,
                         :space => space)
    end

    context "and itself is a page" do
      let(:subject) do
        Factory(:lecture, :subject => @sub, :owner => @sub.owner,
                :lectureable => Factory(:page))
      end

      before do
        @new_lecture = subject.clone_for_subject!(@new_subject.id)
      end

      it "generates a lecture differente of itself" do
        @new_lecture.should_not == subject
      end

      it "generates a clone" do
        @new_lecture.should be_is_clone
      end

      it "generates a clone that belongs to correct subject" do
        @new_lecture.subject.should == @new_subject
      end
    end

    context "and itself is a external seminar" do
      let(:subject) do
        Factory(:lecture, :subject => @sub, :owner => @sub.owner,
                :lectureable => Factory(:seminar_youtube))
      end

      before do
        @new_lecture = subject.clone_for_subject!(@new_subject.id)
      end

      it "generates a lecture differente of itself" do
        @new_lecture.should_not == subject
      end

      it "generates a clone" do
        @new_lecture.should be_is_clone
      end

      it "generates a clone that belongs to correct subject" do
        @new_lecture.subject.should == @new_subject
      end

      context "when clonning external resource url" do
        it "should be the same url" do
          @new_lecture.lectureable.external_resource_url.should == \
            subject.lectureable.external_resource_url
        end
      end
    end

    context "and itself is a exercise" do
      let(:subject) do
        Factory(:lecture, :subject => @sub, :owner => @sub.owner,
                :lectureable => Factory(:complete_exercise))
      end

      before do
        @new_lecture = subject.clone_for_subject!(@new_subject.id)
      end

      it "generates a lecture differente of itself" do
        @new_lecture.should_not == subject
      end

      it "generates a clone" do
        @new_lecture.should be_is_clone
      end

      it "generates a clone that belongs to correct subject" do
        @new_lecture.subject.should == @new_subject
      end

      context "when cloning questions" do
        it "generates a clone that contains all questions" do
          subject_q = attrs_except(subject.lectureable.questions,
                                   ["id","exercise_id"])
          new_lecture_q = attrs_except(@new_lecture.lectureable.questions,
                                       ["id","exercise_id"])

          subject_q.to_set.should == new_lecture_q.to_set
        end

        context "when cloning alternatives" do
          it "generates a clone that each question contain all alternatives" do
            subject_a = subject.lectureable.questions.collect do |q|
              attrs_except(q.alternatives, ["id","question_id"])
            end

            new_lecture_a = @new_lecture.lectureable.questions.collect do |q|
              attrs_except(q.alternatives, ["id","question_id"])
            end

            subject_a.to_set.should == new_lecture_a.to_set
          end
        end
      end
    end
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
      grade = Enrollment.sum('grade', :conditions =>
                             {:subject_id => subject.subject.id})
      grade.should == 100

      @lec.destroy
      @lec.subject.reload
      @lec.refresh_students_profiles
      grade = Enrollment.sum('grade', :conditions =>
                             {:subject_id => subject.subject.id})
      grade.should == 0
    end
  end

  it "verifies if a lecture was done by a user" do
    subject_owner = Factory(:user)
    space = Factory(:space)
    space.course.join subject_owner
    subject1 = Factory(:subject, :owner => subject_owner,
                       :space => space)
    lectures = (1..3).collect { Factory(:lecture, :subject => subject1) }

    user = Factory(:user)
    subject1.enroll user

    lectures[0].done?(user).should be_false
  end

  it "indicates if it is recent (created until 1 week ago)" do
    subject.should be_recent

    subject.created_at = 10.day.ago
    subject.save
    subject.should_not be_recent
  end

  context "nested lectureable" do
    before do
      @owner = Factory(:user)
      @sub = Factory(:subject)
    end
    context "when valid" do
      before do
        @lecture = Lecture.new({ :name => "Name", :subject => @sub,
                                "lectureable_attributes" => {
                                  "_type" => "Page", "body" => "Cool letters"} })
        @lecture.owner = @owner
      end

      it "builds a lecture within a lectureable" do
        @lecture.should_not be_nil
        @lecture.lectureable.should_not be_nil
      end

      it "saves a lecture" do
        expect {
          @lecture.save
        }.should change(Lecture, :count).by(1)
      end

      it "saves a lectureable (Page)" do
        expect {
          @lecture.save
        }.should change(Page, :count).by(1)
      end
    end

    context "when invalid" do
      before do
        @lecture = Lecture.new({ :name => "Name", :subject => @sub,
                                 "lectureable_attributes" => {"_type" => "Page"}})
        @lecture.owner = @owner
      end

      it "builds a lecture within a lectureable" do
        @lecture.should_not be_nil
        @lecture.lectureable.should_not be_nil
      end

      it "validates lectureable" do
        @lecture.lectureable.should_not be_valid
      end

      it "does NOT save a lecture" do
        expect {
          @lecture.save
        }.should_not change(Lecture, :count)
      end

      it "does NOT save a lectureable (Page)" do
        expect {
          @lecture.save
        }.should_not change(Page, :count)
      end
    end


    context "when building attributes" do
      context "when Exercise" do
        before do
          @alternatives = {
            "1" => {:text => "Lorem ipsum dolor", :correct => true},
            "2" => {:text => "Lorem ipsum dolor"},
            "3" => {:text => "Lorem ipsum dolor"}
          }
          @questions = 3.times.collect do
            { :statement => "Lorem ipsum dolor sit amet, consectetur?",
              :explanation => "Lorem ipsum dolor sit amet?",
              :alternatives_attributes => @alternatives.clone }
          end

          @params = { :lecture =>
                      { :name => "Cool lecture",
                        :lectureable_attributes =>
                      { :_type => 'Exercise',
                        :questions_attributes => @questions }}}
        end

        it "should build the Exercise" do
          lecture = Lecture.new(@params[:lecture])
          lecture.should be_valid
        end

        it "should create the Exercise" do
          expect {
            Lecture.create(@params[:lecture]) do |lecture|
            lecture.owner = @sub.owner
            lecture.subject = @sub
            end
          }.should change(Exercise, :count).by(1)
        end

        it "should return nil when there is not a _type" do
          subject.build_lectureable({}).should be_nil
        end

        it "should return nil when type is blank" do
          subject.build_lectureable({ :_type => '' }).should be_nil
        end
      end

      context "when Existent" do
        it "returns nil when type is Existent" do
          subject.build_lectureable({ :_type => 'Existent'}).should be_nil
        end
      end
    end
  end

  protected
  def attrs_except(entities, attrs_to_remove)
    entities.collect do |entity|
      attrs = entity.attributes

      attrs_to_remove.each do |attr|
        attrs.delete(attr)
      end
      attrs
    end
  end
end
