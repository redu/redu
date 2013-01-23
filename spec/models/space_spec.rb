require 'spec_helper'

describe Space do

  subject { Factory(:space) }

  [:user_space_associations, :users, :teachers, :students,
    :logs, :folders, :statuses, :subjects ].each do |attr|
      it { should have_many(attr) }
  end

  it { should belong_to :course }
  it { should belong_to :owner }

  it { should have_one :root_folder}
  it { should have_many :canvas }

  it { should have_many :logs }
  it { should have_many :statuses }

  it { should validate_presence_of :name}
  it { should_not validate_presence_of :description }
  it { should ensure_length_of(:name).is_at_most 40 }

  [:owner, :removed, :members_count, :course_id, :published].each do |attr|
    it { should_not allow_mass_assignment_of attr }
  end

  context "callbacks" do
    it "creates a root folder" do
      expect {
        space = Factory(:space)
      }.should change(Folder, :count).by(1)
    end

    it "creates a space association with all users of course's spaces" do
      c = Factory(:course)
      users = (1..4).collect { Factory(:user) }
      c.users << [users[0], users[1], users[2]]
      users[0].user_course_associations.last.approve!
      users[1].user_course_associations.last.approve!
      users[2].user_course_associations.last.approve!
      s = Factory(:space, :owner => users[2], :course => c)
      s.users.should == c.users
    end
  end

  context "finders" do
    it "retrieves finalized subjects" do
      user = Factory(:user)
      subject.course.join user
      subjects = (1..3).collect { Factory(:subject, :owner => user,
                                          :space => subject) }
      finalized_subjects = (1..3).collect { Factory(:subject, :owner => user,
                                                    :space => subject,
                                                    :finalized => true) }
      subject.subjects.should == finalized_subjects
    end


    it "retrieves all administrators" do
      users = 5.times.inject([]) { |res, i| res << Factory(:user) }
      Factory(:user_space_association, :user => users[0],
              :space => subject, :role => :environment_admin)
      Factory(:user_space_association, :user => users[1],
              :space => subject, :role => :environment_admin)
      Factory(:user_space_association, :user => users[2],
              :space => subject, :role => :teacher)
      Factory(:user_space_association, :user => users[3],
              :space => subject, :role => :tutor)
      Factory(:user_space_association, :user => users[4],
              :space => subject, :role => :member)

      subject.administrators.to_set.
        should == [users[0], users[1], subject.course.environment.owner].to_set
    end

    it "retrieves all teachers" do
      users = 5.times.inject([]) { |res, i| res << Factory(:user) }
      Factory(:user_space_association, :user => users[0],
              :space => subject, :role => :environment_admin)
      Factory(:user_space_association, :user => users[1],
              :space => subject, :role => :teacher)
      Factory(:user_space_association, :user => users[2],
              :space => subject, :role => :teacher)
      Factory(:user_space_association, :user => users[3],
              :space => subject, :role => :tutor)
      Factory(:user_space_association, :user => users[4],
              :space => subject, :role => :member)

      subject.teachers.to_set.
        should == [users[1], users[2]].to_set
    end

    it "retrieves all tutors" do
      users = 5.times.inject([]) { |res, i| res << Factory(:user) }
      Factory(:user_space_association, :user => users[0],
              :space => subject, :role => :environment_admin)
      Factory(:user_space_association, :user => users[1],
              :space => subject, :role => :teacher)
      Factory(:user_space_association, :user => users[2],
              :space => subject, :role => :tutor)
      Factory(:user_space_association, :user => users[3],
              :space => subject, :role => :tutor)
      Factory(:user_space_association, :user => users[4],
              :space => subject, :role => :member)

      subject.tutors.to_set.
        should == [users[2], users[3]].to_set
    end

    it "retrieves all students" do
      users = 5.times.inject([]) { |res, i| res << Factory(:user) }
      Factory(:user_space_association, :user => users[0],
              :space => subject, :role => :environment_admin)
      Factory(:user_space_association, :user => users[1],
              :space => subject, :role => :teacher)
      Factory(:user_space_association, :user => users[2],
              :space => subject, :role => :tutor)
      Factory(:user_space_association, :user => users[3],
              :space => subject, :role => :member)
      Factory(:user_space_association, :user => users[4],
              :space => subject, :role => :member)

      subject.students.to_set.
        should == [users[3], users[4]].to_set
    end

    it "retrieves new users from 1 week ago" do
      users = 5.times.inject([]) { |res, i| res << Factory(:user) }
      Factory(:user_space_association, :user => users[0],
              :space => subject, :role => :environment_admin,
             :updated_at => 2.weeks.ago)
      Factory(:user_space_association, :user => users[1],
              :space => subject, :role => :teacher,
             :updated_at => 2.weeks.ago)
      Factory(:user_space_association, :user => users[2],
              :space => subject, :role => :tutor,
             :updated_at => 2.weeks.ago)
      Factory(:user_space_association, :user => users[3],
              :space => subject, :role => :member,
             :updated_at => 2.weeks.ago)
      Factory(:user_space_association, :user => users[4],
              :space => subject, :role => :member)

      #FIXME modificar a criação do space, já que está destoante da aplicação
      subject.new_members.to_set.
        should == [subject.course.environment.owner, users[4]].to_set
    end

    it "retrieves myfiles" do
      spaces = (1..5).collect { Factory(:space) }
      other_files = (0..4).collect do |n|
        Factory(:myfile, :folder => spaces[n].root_folder)
      end
      files = (1..4).collect { Factory(:myfile,
                                       :folder => subject.root_folder) }
      subject.myfiles.should == files
    end

    it "retrieves all spaces that user is teacher" do
      spaces = (1..5).collect { Factory(:space) }
      user = Factory(:user)
      spaces[0].course.join(user, Role[:teacher])
      spaces[1].course.join(user, Role[:teacher])
      spaces[2].course.join(user, Role[:member])
      spaces[3].course.join(user, Role[:tutor])

      user.spaces.teachers.to_set.should ==
        [spaces[0], spaces[1]].to_set
    end

    it "retrieves all my subjects ids" do
      subj = (1..2).collect { Factory(:subject, :space => subject) }

      subject.subjects << subj[0]
      subject.subjects << subj[1]

      subject.subjects_id.to_set.should eq([subj[0].id, subj[1].id].to_set)
    end

    it "retrieves all my students ids" do
      students_id = []
      teacher = Factory(:user)
      subject.course.join(teacher, Role[:teacher])

      2.times do
        user = Factory(:user)
        subject.course.join(user, Role[:member])
        students_id << user.id
      end

      subject.students_id.to_set.should == students_id.to_set
    end
  end

  it "changes a user role" do
    user = Factory(:user)
    subject.users << user
    subject.save

    expect {
      # have to play the bootstrap:roles for the test environment
      subject.change_role(user, Role[:teacher])
    }.should change {
      subject.user_space_associations.last.role }.to(Role[:teacher])

  end

  context "when counting lectures" do
    before do
      @lectures = 3.times.inject([]) do |acc,i|
        subj = Factory(:subject, :owner => subject.owner,
                       :space => subject,
                       :visible => true, :finalized => true)
        lectures = 3.times.inject([]) do |mem, i|
          mem << Factory(:lecture, :subject => subj)
        end
        acc << lectures
      end.flatten!
    end

    it "should count correctly" do
      subject.lectures_count.should == @lectures.size
    end
  end
end
