require 'spec_helper'

describe Status do
  it { should belong_to(:statusable) }
  it { should have_many(:users).through(:status_user_associations) }
  it { should have_many(:status_user_associations).dependent(:destroy) }

  context "scopes" do
    before do
      @environment = Factory(:environment)
      @course = Factory(:course, :environment => @environment,
                        :owner => @environment.owner)

      @course.join(@environment.owner)

      @spaces = 3.times.inject([]) do |acc,i|
        acc << Factory(:space, :owner => @course.owner, :course => @course)
      end

      @lectures = 3.times.inject([]) do |acc,i|
        sub = Factory(:subject, :owner => @spaces.first.owner,
                      :space => @spaces.first,
                      :finalized => true)
        lect = Factory(:lecture, :owner => @spaces.first.owner,
                       :lectureable => Factory(:page), :subject => sub)

        acc << lect
      end

      @space_statuses = @spaces.collect do |e|
        3.times.inject([]) do |acc,i|
          acc << Factory(:activity, :statusable => e, :user => @course.owner)
        end
      end.flatten

      @course_statuses = 3.times.inject([]) do |acc,i|
        acc << Factory(:activity, :statusable => @course, :user => @course.owner)
      end

       @lecture_statuses = @lectures.collect do |l|
         3.times.inject([]) do |acc,i|
           acc << Factory(:activity, :statusable => l, :user => @course.owner)
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
          Factory(:activity, :statusable => @spaces.first, :user => @course.owner,
                  :created_at => 3.weeks.ago)
        end

        @recent_space_statuses = (1..3).collect do
          Factory(:activity, :statusable => @spaces.first, :user => @course.owner,
                  :created_at => 5.days.ago)
        end
      end

      it "retrieves recent space statuses" do
        statuses = @space_statuses.select { |s| s.statusable == @spaces.first }
        Status.recent_from_hierarchy(@spaces.first).to_set.should \
          be_superset((statuses | @recent_space_statuses).to_set)
      end
    end
  end
end
