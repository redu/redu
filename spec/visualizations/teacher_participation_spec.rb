# -*- encoding : utf-8 -*-
require 'spec_helper'

describe TeacherParticipation do
  before(:each) do
    @owner = FactoryGirl.create(:user)
    @teacher = FactoryGirl.create(:user)
    @environment = FactoryGirl.create(:environment, :owner => @owner)
    @course = FactoryGirl.create(:course, :owner => @owner,
                      :environment => @environment)
    @space_statuses = []
    @lecture_statuses = []
    @ans = []

    @ini = "2012-02-15".to_date
    @end = "2012-02-16".to_date

    2.times.collect  do
      s = FactoryGirl.create(:space, :course => @course)
      su = FactoryGirl.create(:subject, :space => s,
                   :owner => @owner, :finalized => true)
      l = FactoryGirl.create(:lecture, :subject => su, :owner => @teacher,
                  :created_at => @end)

      @space_statuses += 3.times.collect do
        FactoryGirl.create(:activity,
                :statusable => s, :user => @teacher,
                :created_at => @end)
      end

      @lecture_statuses += 3.times.collect do
        FactoryGirl.create(:activity,
                :statusable => l, :user => @teacher,
                :created_at => @end)
      end

      @ans += 2.times.collect do
        acti = FactoryGirl.create(:activity, :statusable => l, :user => FactoryGirl.create(:user),
               :created_at => @end)
        FactoryGirl.create(:answer, :statusable => l,
                :in_response_to => acti, :user => @teacher,
                :created_at => @end)
      end

      su.lectures << l
      s.subjects << su
      @course.spaces << s
    end


    s = FactoryGirl.create(:space, :course => @course)
    su = FactoryGirl.create(:subject, :space => s,
                 :owner => @owner, :finalized => true)
    l = FactoryGirl.create(:lecture, :subject => su,
                :owner => @teacher, :created_at => @ini)

    3.times.collect do
      FactoryGirl.create(:activity,
              :statusable => s, :user => @teacher,
              :created_at => @ini)
    end

    3.times.collect do
      FactoryGirl.create(:activity,
              :statusable => l, :user => @teacher,
              :created_at => @ini)
    end

    2.times.collect do
      FactoryGirl.create(:answer, :statusable => l,
              :in_response_to => l.statuses.first, :user => @teacher,
              :created_at => @ini)
    end

    su.lectures << l
    s.subjects << su
    @course.spaces << s

    @course.teachers << @teacher
    @uca = @teacher.get_association_with(@course)
  end

  subject { TeacherParticipation.new(@uca) }

  it { should respond_to :lectures_created }
  it { should respond_to :posts}
  it { should respond_to :answers }
  it { should respond_to :days }
  it { should_not respond_to :lectures_created= }
  it { should_not respond_to :posts=}
  it { should_not respond_to :answers= }
  it { should_not respond_to :days= }
  it { should respond_to :end }
  it { should respond_to :end=}
  it { should respond_to :start }
  it { should respond_to :start= }
  it { should respond_to :spaces }
  it { should respond_to :spaces=}

  it "initialize correctly" do
    subject.end.should == Date.today
    subject.spaces.to_set.should == @course.spaces.to_set
  end

  context "queries" do
    it "retrieves all subjects ids from specified spaces" do
      subject.spaces = [@course.spaces.first]
      @id = subject.spaces.first.subjects.first.id
      subject.subjects_by_space.should eq([@id])
    end

    it "retrieves the lectures ids that belongs the User from the
    especified spaces" do
      subject.spaces = [@course.spaces.first]
      @lecture = FactoryGirl.create(:lecture,
                         :subject => subject.spaces.first.subjects.first,
                         :owner => @owner)
      subject.spaces.first.subjects.first.lectures << @lecture
      subject.lectures_created_by_space.should \
        eq([subject.spaces.first.subjects.first.lectures.first])
    end

    it "retrieves all posts that belongs the User from especified spaces" do
      2.times do
        FactoryGirl.create(:activity,
                :statusable => subject.spaces.first, :user => @owner)
        FactoryGirl.create(:activity,
                :statusable => subject.spaces.first.subjects.first.
                               lectures.first,
                :user => @owner)
      end

      subject.spaces = @course.spaces[0..1]
      subject.subjects_by_space
      subject.posts_by_space.collect{|s| s.id}.to_set.should \
        eq((@space_statuses + @lecture_statuses).collect{ |s| s.id }.to_set)
    end

    it "retrieves all answers made by User from specified spaces" do
      2.times do
        FactoryGirl.create(:activity,
                :statusable => subject.spaces.first, :user => @owner)
        FactoryGirl.create(:activity,
                :statusable => subject.spaces.first.subjects.first.
                               lectures.first,
                :user => @owner)
      end

      subject.spaces = @course.spaces[0..1]
      subject.subjects_by_space
      subject.posts_by_space
      subject.answers_by_space.collect{|a| a.id}.to_set.should \
        eq((@ans).collect{|a| a.id}.to_set)
    end
  end

  context "building" do
    it "queries by specified days" do
      subject.start = @ini
      subject.end = @end
      subject.generate!

      subject.lectures_created[0].should == 1
      subject.posts[0].should == 6
      subject.answers[0].should == 2
      subject.days.size == 2
    end
  end
end
