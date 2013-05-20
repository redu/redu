# -*- encoding : utf-8 -*-
shared_examples_for "activity on lecture" do
  it "should be able to read if member" do
    space.course.join(user)
    subject.should be_able_to :read, status
  end

  it "should not be able to read if not member" do
    subject.should_not be_able_to :read, status
  end

  it "should be able to manage if environment_admin" do
    space.course.join(user, Role[:environment_admin])
    subject.should be_able_to :manage, status
  end

  it "should not be able to manage if member" do
    space.course.join(user)
    subject.should_not be_able_to :manage, status
  end

  it "should be able to manage if teacher" do
    space.course.join(user, Role[:teacher])
    subject.should be_able_to :manage, status
  end
end
