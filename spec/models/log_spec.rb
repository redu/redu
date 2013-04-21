require 'spec_helper'

describe Log do
  subject { Factory(:log) }

  it { should validate_presence_of :action }
  it { should belong_to(:logeable) }
  it { should belong_to(:compound_log) }

  it "assigns type" do
    subject.type.should == subject.class.to_s
  end

  context "when setting up courses" do
    before do
      @course = Factory(:course)
    end

    it "logs creation" do
      log = Log.setup(@course)
      log.should_not be_nil
      log.should be_valid
      log.logeable.should == @course
      log.statusable.should == @course.owner
    end

    it "accepts extra options" do
      log = Log.setup(Factory(:course), :action => :update, :save => false)
      log.should_not be_nil
      log.should be_new_record
      log.action.should == :update
    end
  end

  context "when setting up UserCourseAssociation" do
    it "cannot log if is waiting" do
      uca = Factory(:user_course_association)
      log = Log.setup(uca)
      log.should be_nil
    end

    it "accepts extra options" do
      uca = Factory(:user_course_association)
      uca.approve!
      log = Log.setup(uca, :save => false)
      log.should_not be_nil
      log.should be_valid
      log.should be_new_record
    end

    context "when is approved" do
      before do
        @uca = Factory(:user_course_association)
        @uca.approve!
        @log = Log.setup(@uca)
      end

      it "logs creation" do
        @log.should_not be_nil
        @log.should be_valid
      end

      it "sets UserCourseAssociation as logeable" do
        @log.logeable.should == @uca
      end

      it "set Course as statusable" do
        @log.statusable.should == @uca.course
      end
    end
  end

  context "when setting up Space" do
    it "accepts extra options" do
      space = Factory(:space)
      log = Log.setup(space, :save => false, :action => :update)

      log.should_not be_nil
      log.should be_new_record
      log.action.should == :update
    end

    context "with no options" do
      before do
        @space = Factory(:space)
        @log = Log.setup(@space)
      end

      it "logs creation" do
        @log.should_not be_nil
        @log.should be_valid
        @log.action.should == :create
      end

      it "sets Space as logeable" do
        @log.logeable.should == @space
      end

      it "sets Course as statusable" do
        @log.statusable.should == @space.course
      end
    end
  end

  context "when setting up Subject" do
    it "cannot log creation if unfinalized (default)" do
      @subject = Factory(:subject)
      log = Log.setup(@subject)
      log.should be_nil
    end

    it "accepts extra options" do
      @subject = Factory(:subject, :visible => true)
      @subject.finalized = true
      @subject.save
      log = Log.setup(@subject, :save => false)
      log.should_not be_nil
      log.should be_new_record
    end

    context "when finalized and public" do
      before do
        @subject = Factory(:subject, :visible => true)
        @subject.finalized = true
        @subject.save

        @log = Log.setup(@subject)
      end

      it "logs creation" do
        @log.should_not be_nil
        @log.should be_valid
      end

      it "cannot double log" do
        expect {
          Log.setup(@subject)
        }.should_not change(@subject.logs, :count)
      end

      it "sets Space as statusable" do
        @log.statusable.should == @subject.space
      end

      it "sets Subject as logeable" do
        @log.logeable.should == @subject
      end

      it "sets the subject owner as user" do
        @log.user.should == @subject.owner
      end
    end
  end

  context "when setting up Lecture" do
    it "cannot log creation if the subject invisible or unfinalized" do
      sub = Factory(:subject)
      @lecture = Factory(:lecture, :subject => sub,
                         :owner => sub.owner)
      log = Log.setup(@lecture)
      log.should be_nil
    end

    it "accepts extra options" do
      sub = Factory(:subject, :visible => true)
      @lecture = Factory(:lecture, :subject => sub,
                         :owner => sub.owner)
      @lecture.subject.finalized = true
      @lecture.subject.save
      log = Log.setup(@lecture, :save => false)
      log.should_not be_nil
      log.should be_new_record
    end

    context "when public avaliable and finilized" do
      before do
        environment = Factory(:environment)
        course = Factory(:course, :owner => environment.owner,
                         :environment => environment)
        @space = Factory(:space, :owner => environment.owner,
                        :course => course)
        user = Factory(:user)
        course.join(user)
        sub = Factory(:subject, :owner => user, :space => @space,
                      :visible => true)
        sub.enroll
        @lecture = Factory(:lecture, :subject => sub,
                         :owner => sub.owner)
        @lecture.subject.finalized = true
        @lecture.subject.save
        @seminar = Factory(:seminar_youtube, :lecture => @lecture)
        @log = Log.setup(@lecture)
      end

      it "logs creation" do
        @log.should_not be_nil
        @log.should be_valid
      end

      it "sets Lecture as logeable" do
        @log.logeable.should == @lecture
      end

      it "sets Space as statusable" do
        @log.statusable.should == @space
      end

      it "sets owner as user" do
        @log.user.should == @lecture.owner
      end
    end
  end

  context "when updating User" do
    before do
      @user = Factory(:user)
      @user.first_name = "New name"
      @log = Log.setup(@user, :action => :update)
    end

    it "logs update" do
      @log.should_not be_nil
      @log.should be_valid
      @log.action.should == :update
    end

    it "sets user as logeable and statusable" do
      @log.logeable.should == @user
      @log.statusable.should == @user
    end

    it "sets the correct message" do
      @log.action_text.should =~ /atualizou o perfil/
    end
  end

  context "when updating Experience" do
    before do
      @exp = Factory(:experience)
      @log = Log.setup(@exp, :action => :update)
    end

    it "logs update" do
      @log.should_not be_nil
      @log.should be_valid
    end

    it "set Experience as logeable" do
      @log.logeable.should == @exp
    end

    it "sets User as statusable" do
      @log.statusable.should == @exp.user
    end
  end

  context "when creating Education" do
    before do
      @education = Factory(:education)
      @log = Log.setup(@education, :action => :update)
    end

    it "logs update" do
      @log.should_not be_nil
      @log.should be_valid
      @log.should_not be_new_record
    end

    it "set Education as logeable" do
      @log.logeable.should == @education
    end

    it "sets User as statusable" do
      @log.statusable.should == @education.user
    end
  end

  context "when updating Frienship" do

    it "cannot log if is unapproved" do
      @user1 = Factory(:user)
      @user2 = Factory(:user)
      @user1.be_friends_with(@user2)

      friendship = @user1.friendships.first
      log = Log.setup(friendship)
      log.should be_nil
    end

    context "when approved" do
      before do
        @user1 = Factory(:user)
        @user2 = Factory(:user)
        @user1.be_friends_with(@user2)
        @user2.be_friends_with(@user1)

        @friendship = @user1.friendships.first
        @log = Log.setup(@friendship)
      end

      it "logs friendship" do
        @log.should_not be_nil
      end

      it "sets User as logeable and statusable" do
        @log.logeable.should == @user1.friendship_for(@user2)
        @log.statusable.should == @user1
      end
    end

    describe :process_compound do
      context "when compound logs are processed" do
        context "and log type is friendship" do
          before do
            @robert = Factory(:user, :login => 'robert_baratheon')
            @ned = Factory(:user, :login => 'eddard_stark')
            @jhon = Factory(:user, :login => 'jhon_arryn')
          end

          context "and compound log already exists" do
            before do
              ActiveRecord::Observer.with_observers(
                :friendship_observer,
                :status_observer,
                :log_observer) do
                  @robert.be_friends_with(@ned)
                  @ned.be_friends_with(@robert)
              end
            end

            it "should include new logs when these appear" do
              @robert_compound = CompoundLog.where(:statusable_id => @robert.id).last
              ActiveRecord::Observer.with_observers(
                :friendship_observer,
                :status_observer,
                :log_observer) do
                  expect {
                    @robert.be_friends_with(@jhon)
                    @jhon.be_friends_with(@robert)
                    @robert_compound.reload
                  }.should change(@robert_compound.logs, :count).from(1).to(2)
              end
            end
          end

          context "and compound log don't exists" do
            it "should create a new compound log for each user" do
              ActiveRecord::Observer.with_observers(
                :friendship_observer,
                :status_observer,
                :log_observer) do
                  expect {
                    @robert.be_friends_with(@ned)
                    @ned.be_friends_with(@robert)
                  }.should change(CompoundLog, :count).by(2)
              end
            end
          end
        end

        context "and log type is user course association" do
          before do
            @aemon = Factory(:user, :login => 'aemon_targaryen')
            @users = 3.times.collect { Factory(:user) }
          end

          context "and compound log already exists" do
            before do
              ActiveRecord::Observer.with_observers(
                :user_course_association_observer,
                :status_observer,
                :log_observer) do
                  @course = Factory(:course)
                  @course.join(@aemon)
              end
            end

            it "should include new logs when these appear" do
              @course_compound = CompoundLog.where(:statusable_id => @course.id).last
              ActiveRecord::Observer.with_observers(
                :user_course_association_observer,
                :status_observer,
                :log_observer) do
                  expect {
                    @users.each { |u| @course.join(u) }
                    @course_compound.reload
                  }.should change(@course_compound.logs, :count)
              end
            end
          end

          context "and compound log don't exists" do
            it "should create a new compound log for each user" do
              ActiveRecord::Observer.with_observers(
                :user_course_association_observer,
                :status_observer,
                :log_observer) do
                  expect {
                    @course = Factory(:course)
                    @course.join(@aemon)
                  }.should change(CompoundLog, :count).by(1)
              end
            end
          end
        end
      end
    end
  end
end
