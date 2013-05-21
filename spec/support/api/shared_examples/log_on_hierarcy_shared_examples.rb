# -*- encoding : utf-8 -*-
shared_examples_for "log on hierarchy" do
  it "should be able to read if member" do
    course.join(user)
    subject.should be_able_to :read, log
  end

  it "should not be able to read if not member" do
    subject.should_not be_able_to :read, log
  end

  it "should not be able to manage if environment_admin" do
    course.join(user, Role[:environment_admin])
    subject.should_not be_able_to :manage, log
  end

  it "should not be able to manage if member" do
    course.join(user)
    subject.should_not be_able_to :manage, log
  end

  it "should not be able to manage if teacher" do
    course.join(user, Role[:teacher])
    subject.should_not be_able_to :manage, log
  end
end

