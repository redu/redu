require 'spec_helper'

describe Space do

  subject { Factory(:space) }

  [:user_space_associations, :users, :teachers, :students,
    :logs, :folders, :bulletins, :events, :statuses, :subjects,
    :topics, :sb_posts].each do |attr|
      it { should have_many(attr) }
  end

  it { should belong_to :course }
  it { should belong_to :owner }

  it { should have_one :forum }
  it { should have_one :root_folder}

  it { should have_many :logs }
  it { should have_many :statuses }

  it { should validate_presence_of :name}
  it { should validate_presence_of :description }
  it { should validate_presence_of :submission_type }
  it { should ensure_length_of(:name).is_at_most 40 }
  #FIXME falhando por problema de tradução
  xit { should ensure_length_of(:description).is_at_least(30).is_at_most(250) }


  [:owner, :removed, :lectures_count,
   :members_count, :course_id, :published].each do |attr|
    it { should_not allow_mass_assignment_of attr }
  end

  context "callbacks" do
    it "creates a root folder" do
      expect {
        space = Factory(:space)
      }.should change(Folder, :count).by(1)
    end

    it "creates a forum" do
      expect{
        s = Factory(:space)
      }.should change(Forum, :count).by(1)
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
  end

  it "generates a permalink" do
    @space = Factory(:space, :id => 123, :name => "teste")
    Redu::Application.config.url.should_not be_nil
    @space.permalink.should include("#{@space.id}-#{@space.name.parameterize}")
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

  it "change to published" do
    space = Factory(:space, :published => false)
    expect {
      space.publish!
    }.should change { space.published }.to(true)
  end

  it "change to unpublished" do
    space = Factory(:space, :published => true)
    expect{
      space.unpublish!
    }.should change { space.published }.to(false)
  end

end
