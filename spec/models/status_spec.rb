# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Status do
  it { should belong_to(:statusable) }
  it { should have_many(:users).through(:status_user_associations) }
  it { should have_many(:status_user_associations).dependent(:delete_all) }
  it { should have_many(:status_resources).dependent(:delete_all) }
  it { should have_many(:answers).dependent(:delete_all) }

  context "scopes" do
    before do
      @environment = FactoryGirl.create(:environment)
      @course = FactoryGirl.create(:course, :environment => @environment,
                        :owner => @environment.owner)

      @course.join(@environment.owner)

      @spaces = 3.times.inject([]) do |acc,i|
        acc << FactoryGirl.create(:space, :owner => @course.owner, :course => @course)
      end

      @lectures = 3.times.inject([]) do |acc,i|
        sub = FactoryGirl.create(:subject, :owner => @spaces.first.owner,
                      :space => @spaces.first,
                      :finalized => true)
        lect = FactoryGirl.create(:lecture, :owner => @spaces.first.owner,
                       :lectureable => FactoryGirl.create(:page), :subject => sub)

        acc << lect
      end

      @space_statuses = @spaces.collect do |e|
        3.times.inject([]) do |acc,i|
          acc << FactoryGirl.create(:activity, :statusable => e, :user => @course.owner)
        end
      end.flatten

      @course_statuses = 3.times.inject([]) do |acc,i|
        acc << FactoryGirl.create(:activity, :statusable => @course, :user => @course.owner)
      end

       @lecture_statuses = @lectures.collect do |l|
         3.times.inject([]) do |acc,i|
           acc << FactoryGirl.create(:activity, :statusable => l, :user => @course.owner)
         end + \
         3.times.inject([]) do |acc,i|
           acc << FactoryGirl.create(:help, :statusable => l, :user => @course.owner)
         end
       end.flatten
    end

    context "from course" do
      it "retrieves course statuses" do
        Status.from_hierarchy(@course).to_set.should \
          be_superset(@space_statuses.to_set)
        Status.from_hierarchy(@course).to_set.should \
          be_superset(@course_statuses.to_set)
        Status.from_hierarchy(@course).to_set.should \
          be_superset(@lecture_statuses.to_set)
      end
    end

    context "from space" do
      it "retrieves space statuses" do
        statuses = @space_statuses.select { |s| s.statusable == @spaces.first }
        Status.from_hierarchy(@spaces.first).to_set.should \
          be_superset(statuses.to_set)
        Status.from_hierarchy(@lectures.first).to_set.should \
          be_subset(@lecture_statuses.to_set)
      end
    end

    context "from lecture" do
      it "retrieves lecture statuses" do
        Status.from_hierarchy(@lectures.first).to_set.should \
          be_subset(@lecture_statuses.to_set)
      end
    end

    context "recent" do
      before do
        @old_space_statuses = (1..3).collect do
          FactoryGirl.create(:activity, :statusable => @spaces.first, :user => @course.owner,
                  :created_at => 3.weeks.ago)
        end

        @recent_space_statuses = (1..3).collect do
          FactoryGirl.create(:activity, :statusable => @spaces.first, :user => @course.owner,
                  :created_at => 5.days.ago)
        end
      end

      it "retrieves recent space statuses" do
        statuses = @space_statuses.select { |s| s.statusable == @spaces.first }
        Status.recent_from_hierarchy(@spaces.first).to_set.should \
          be_superset((statuses | @recent_space_statuses).to_set)
      end
    end

    context "filtering" do
      before do
        @user = FactoryGirl.create(:user)
        @activity_statuses = (1..2).collect {
          FactoryGirl.create(:activity, :user => @user,
                  :statusable => @spaces.first) }
        @activity_statuses << FactoryGirl.create(:activity, :statusable => @spaces.first)
        @activity_statuses << FactoryGirl.create(:activity, :statusable => @spaces.first)
      end

      it "Activities by a specified user" do
        @spaces.first.statuses.activity_by_user(@user.id).to_set.should \
          eq([@activity_statuses[0], @activity_statuses[1]].to_set)
      end

      it "Helps and Activities" do
        @activity_statuses << FactoryGirl.create(:help, :statusable => @lectures.first, :user => @user)
        @activity_statuses << FactoryGirl.create(:help, :statusable => @lectures.first, :user => @user)

        @lectures.first.statuses.helps_and_activities.count.should eq(8)
      end

      it "by statusable" do
        Status.from_hierarchy(@course).by_statusable("Space", [@spaces[0], @spaces[1]]).count.should eq(10)
      end

      it "by id" do
        id = []
        id << @activity_statuses[0].id
        id << @activity_statuses[1].id
        id << @activity_statuses[2].id
        id << @activity_statuses[3].id

        Status.by_id(id).should eq(@activity_statuses)
      end

      it "by day" do
        id = [FactoryGirl.create(:activity, :created_at => "2012-02-14".to_date).id]
        id << FactoryGirl.create(:activity, :created_at => "2012-02-16".to_date).id
        activity = Status.by_id(id)
        activity.by_day("2012-02-14".to_date).should eq([activity.first])
      end

      it "answers id" do
        id = []
        3.times.collect do
          a = FactoryGirl.create(:answer, :user => @user,
                      :in_response_to => @activity_statuses.first)
          id << a.id
          @activity_statuses.first.answers << a
        end

        @activity_statuses.first.answers_ids(@user).should eq(id)
      end
    end

    describe :visible do
      it "should return visible statuses" do
        Status.visible.where_values_hash.should == { "compound" => false }
      end
    end
  end # context scope

  context ".find_and_include_related" do
    it "should delegate to .find with proper options" do
      included = [{ answers: [:user, :status_resources] }, :status_resources]
      Status.should_receive(:find).with(12, include: included)

      Status.find_and_include_related(12)
    end

    it "should allow options override" do
      Status.should_receive(:find).with(12, include: [])

      Status.find_and_include_related(12, include: [])
    end

  end
end
