require 'spec_helper'

describe Space do

  subject { Factory(:space) }

  context "associations" do
    [:course, :owner].each do |attr|
      it "belongs to a #{attr}" do
        should respond_to(attr)
      end
    end

    [:user_space_associations, :users, :teachers, :students,
      :logs, :folders, :bulletins, :events, :statuses, :subjects,
      :topics, :sb_posts].each do |attr|
        it "has many #{attr}" do
          should respond_to(attr)
        end
    end

    [:forum, :root_folder].each do |attr|
      it "has one #{attr}" do
        should respond_to(attr)
      end
    end

  end

  context "validations" do
    [:name, :description, :submission_type].each do |attr|
      it "must have a #{attr}" do
        @space = Factory.build(:space, attr => '')
        @space.should_not be_valid
        @space.errors.on(attr).should_not be_nil
      end
    end
  end

  context "callbacks" do
    it "creates a root folder" do
      expect {
        @space = Factory(:space)
      }.should change(Folder, :count).by(1)
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
      #FIXME bootstrap para environment de test
      subject.change_role(user, 6)
    }.should change {
      subject.user_space_associations.last.role_id }.to(6)

  end

end
