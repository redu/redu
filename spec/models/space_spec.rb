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

  it { should validate_presence_of :name}
  it { should validate_presence_of :description }
  it { should validate_presence_of :submission_type }

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

  it "generates a permalink" do
    @space = Factory(:space, :id => 123, :name => "teste")
    APP_URL.should_not be_nil
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
