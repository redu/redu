require 'spec_helper'
require 'cancan/matchers'

describe Ability do

  context "on hierarchy" do
    before do
      @env_admin = Factory(:user)
      @member = Factory(:user)
      @teacher = Factory(:user)
      @tutor = Factory(:user)
      @redu_admin = Factory(:user, :role => :admin)
    end

    context "on environment -" do

      before do
        @environment = Factory(:environment, :owner => @env_admin)
      end

      context "member" do
        before do
          Factory(:user_environment_association, :environment => @environment,
                  :user => @member, :role => :member)
          @ability = Ability.new(@member)
        end
        it "creates a environment" do
          env = Factory.build(:environment, :owner => @member)
          @ability.should be_able_to(:create, env)
        end

        it "destroys his own environment" do
          @ability.should be_able_to(:destroy, Factory(:environment, :owner => @member))
        end
        it "cannot destroy a strange environment" do
          @ability.should_not be_able_to(:destroy, @environment)
        end
      end

      context "envinronment_admin" do
        before do
          @ability = Ability.new(@env_admin)
        end
        #FIXME aparentemente um usuário pode criar um ambiente em que o owner seja outro usuário
        it "creates a environment" do
          @ability.should be_able_to(:create, Factory.build(:environment,
                                                            :owner => @env_admin))
        end
        it "destroy his own environment" do
          @ability.should be_able_to(:destroy, @environment)
        end

        it "cannot destroy a strange environment" do
          @ability.should_not be_able_to(:destroy,
                                         Factory.build(:environment,
                                                       :owner => @redu_admin))
        end

        it "can preview a environment" do
          Factory(:user_environment_association, :environment => @environment,
                  :user => @member, :role => :member)
          @ability.should be_able_to(:preview, @environment)
        end
      end

      context "teacher" do
        before do
          Factory(:user_environment_association, :environment => @environment,
                  :user => @teacher, :role => :teacher)
          @ability = Ability.new(@teacher)
        end

        it "creates a environment" do
          @ability.should be_able_to(:create,
                                     Factory.build(:environment,
                                                   :owner => @teacher))
        end
        it "destroy his own environment" do
          @ability.should be_able_to(:destroy,
                                     Factory(:environment,
                                             :owner => @teacher))
        end
        it "cannot destroy a strange environment" do
          @ability.should_not be_able_to(:destroy, @environment)
        end
      end

      context "tutor" do
        before do
          Factory(:user_environment_association, :environment => @environment,
                  :user => @tutor, :role => :teacher)
          @ability = Ability.new(@tutor)
        end
        it "creates a environment" do
          @ability.should be_able_to(:create, Factory.build(:environment,
                                                            :owner => @tutor))
        end

        it "destroy his own environment" do
          @ability.should be_able_to(:destroy, Factory(:environment,
                                                       :owner => @tutor))
        end

        it "cannot destroy a strange environment" do
          @ability.should_not be_able_to(:destroy, @environment)
        end

      end

      context "redu admin" do
        before do
          @ability = Ability.new(@redu_admin)
        end
        it "creates a environment" do
          @ability.should be_able_to(:create,
                                     Factory.build(:environment,
                                                   :owner => @redu_admin))
        end

        it "destroy his own environment" do
          @ability.should be_able_to(:destroy, Factory(:environment,
                                                       :owner => @redu_admin))
        end
        it "can destroy a strange environment" do
          @ability.should be_able_to(:destroy, @environment)
        end
      end

      context "strange" do
        before do
          @strange = Factory(:user)
          @ability = Ability.new(@strange)
        end

        it "can preview a environment" do
          @ability.should be_able_to(:preview, @environment)
        end
      end
    end

    context "on course -" do
      before do
        @environment = Factory(:environment, :owner => @env_admin)
      end

      context "member" do
        before do
          @ability = Ability.new(@member)
          Factory(:user_environment_association, :environment => @environment,
                  :user => @member, :role => :member)
        end

        it "cannot create a course" do
          course = Factory.build(:course,:owner => @environment.owner,
                                 :environment => @environment)
          Factory(:user_course_association, :course => course,
                  :user => @member, :role => :member,
                  :state => "approved")

          @ability.should_not be_able_to(:create, course)
        end

        it "cannot destroy a course" do
          course = Factory.build(:course,:owner => @environment.owner,
                                 :environment => @environment)
          Factory(:user_course_association, :course => course,
                  :user => @member, :role => :member,
                  :state => "approved")

          @ability.should_not be_able_to(:destroy, course)
        end

        it "accepts a course invitation" do
          course = Factory(:course, :owner => @env_admin,
                           :environment => @environment)
          course.invite(@member)
          @ability.should be_able_to(:accept, course)
        end

        it "denies a course invitation" do
          course = Factory(:course, :owner => @env_admin,
                           :environment => @environment)
          course.invite(@member)
          @ability.should be_able_to(:deny, course)
        end

        it "cannot invite users" do
          course = Factory.build(:course,:owner => @environment.owner,
                                 :environment => @environment)

          @ability.should_not be_able_to(:invite_members, course)
        end

        it "can preview a course" do
          course = Factory(:course, :environment => @environment)
          Factory(:user_course_association, :course => course,
                  :user => @member, :role => :member)
          @ability.should be_able_to(:preview, course)
        end

        it "can't see reports" do
          @ability.should_not be_able_to(:teacher_participation_report,
                                     @course)
        end

        it "can't access JSON reports" do
          @ability.should_not be_able_to(:teacher_participation_interaction,
                                     @course)
        end
      end

      context "environment admin" do
        before  do
          @ability = Ability.new(@env_admin)
          @course = Factory.build(:course, :owner => @env_admin,
                                 :environment => @environment)

          Factory(:user_course_association, :course => @course,
                  :user => @env_admin, :role => :environment_admin,
                  :state => "approved")
        end

        it "creates a course"  do
          @ability.should be_able_to(:create, @course)
        end

        it "destroys his course" do
          @ability.should be_able_to(:destroy, @course)
        end

        it "destroys a strange course when he is a environment admin" do
          cur_user = Factory(:user)
          Factory(:user_environment_association, :environment => @environment,
                  :user => cur_user, :role => :environment_admin)
          course = Factory.build(:course, :owner => cur_user,
                                 :environment => @environment)
          @ability.should be_able_to(:destroy, course)
        end

        it "cannot destroy a course when he isn't a environment admin" do
          cur_user = Factory(:user)
          environment_out = Factory(:environment, :owner => cur_user)
          course = Factory.build(:course, :owner => cur_user,
                                 :environment => environment_out)
          @ability.should_not be_able_to(:destroy, course)
        end

        context "if plan is blocked" do
          before do
            @course = Factory(:course,:owner => @env_admin,
                              :environment => @environment)
            @plan = Factory(:active_package_plan, :billable => @course)
            @plan.block!
            @space = Factory(:space, :owner => @env_admin, :course => @course)
            @sub = Factory(:subject, :owner => @env_admin, :space => @space)
          end

          # Sorry, but Document #1 could not be uploaded to Scribd
          pending do
            it "can NOT upload document" do
              document = Factory(:document)
              lecture = Factory(:lecture, :owner => @env_admin,
                                :subject => @sub,
                                :lectureable => document)
              @ability.should_not be_able_to(:upload_document, document)
            end
          end

          # Need Seminar factory
          it "can NOT upload multimedia"

          it "can create a Youtube seminar" do
            youtube = Factory.build(:seminar_youtube)
            lecture = Factory(:lecture, :owner => @env_admin,
                              :subject => @sub,
                              :lectureable => youtube)
            @ability.should be_able_to(:upload_multimedia, youtube)
          end

          # Need Myfile factory
          it "can NOT upload file"
        end

        it "can see reports" do
          @ability.should be_able_to(:teacher_participation_report,
                                     @course)
        end

        it "can access JSON reports" do
          @ability.should be_able_to(:teacher_participation_interaction,
                                     @course)
        end

        it "invites members" do
          @ability.should be_able_to(:invite_members, @course)
        end

        it "views not accepted invitations" do
          @ability.should be_able_to(:admin_manage_invitations, @course)
        end

        it "destroys invitations" do
          @ability.should be_able_to(:destroy_invitations, @course)
        end
      end

      context "teacher" do
        before do
          @ability = Ability.new(@teacher)
          Factory(:user_environment_association, :environment => @environment,
                  :user => @teacher, :role => :teacher)
          @course = Factory(:course,:owner => @environment.owner,
                                 :environment => @environment)
          Factory(:user_course_association, :course => @course,
                  :user => @teacher, :role => :teacher,
                  :state => "approved")
        end

        it "cannot create a course" do
          @ability.should_not be_able_to(:create, @course)
        end
        it "cannot destroy a course" do
          @ability.should_not be_able_to(:destroy, @course)
        end

        it "cannot invite members" do
          @ability.should_not be_able_to(:invite_members, @course)
        end

        it "cannot view not accepted invitations" do
          @ability.should_not be_able_to(:admin_manage_invitations, @course)
        end

        it "cannot destroy invitations" do
          @ability.should_not be_able_to(:destroy_invitations, @course)
        end

        it "can teach course" do
          @ability.should be_able_to(:teach, @course)
        end

        it "can't see reports" do
          @ability.should_not be_able_to(:teacher_participation_report,
                                     @course)
        end

        it "can't access JSON reports" do
          @ability.should_not be_able_to(:teacher_participation_interaction,
                                     @course)
        end
      end

      context "tutor" do
        before do
          @ability = Ability.new(@tutor)
          Factory(:user_environment_association, :environment => @environment,
                  :user => @tutor, :role => :tutor)
          @course = Factory(:course,:owner => @environment.owner,
                                 :environment => @environment)
          Factory(:user_course_association, :course => @course,
                  :user => @tutor, :role => :tutor,
                  :state => "approved")
        end
        it "cannot create a course" do
          @ability.should_not be_able_to(:create, @course)
        end
        it "cannot destroy a course" do
          @ability.should_not be_able_to(:destroy, @course)
        end

        it "cannot invite members" do
          @ability.should_not be_able_to(:invite_members, @course)
        end

        it "can't see reports" do
          @ability.should_not be_able_to(:teacher_participation_report,
                                     @course)
        end

        it "can't access JSON reports" do
          @ability.should_not be_able_to(:teacher_participation_interaction,
                                     @course)
        end
      end

      context "redu admin" do
        before  do
          @ability = Ability.new(@redu_admin)
        end
        it "creates a course"  do
          course = Factory.build(:course, :owner => @redu_admin,
                                 :environment => @environment)
          @ability.should be_able_to(:create, course)
        end
        it "destroys his course" do
          course = Factory.build(:course, :owner => @redu_admin,
                                 :environment => @environment)
          @ability.should be_able_to(:destroy, course)
        end
        it "destroys any course" do
          course = Factory.build(:course,
                                 :environment => @environment)
          @ability.should be_able_to(:destroy, course)
        end

        it "can see reports" do
          course = Factory.build(:course,
                                 :environment => @environment)
          @ability.should be_able_to(:teacher_participation_report,
                                     course)
        end

        it "can access JSON reports" do
          course = Factory.build(:course,
                                 :environment => @environment)
          @ability.should be_able_to(:teacher_participation_interaction,
                                     course)
        end
      end

      context "strange" do
        before do
          @strange = Factory(:user)
          @ability = Ability.new(@strange)
        end

        it "can preview a course" do
          course = Factory(:course, :environment => @environment)
          @ability.should be_able_to(:preview, course)
        end
      end
    end

    context "on space -" do
      before do
        @environment = Factory(:environment, :owner => @env_admin)
        @course = Factory(:course, :owner => @env_admin,
                          :environment => @environment)
        @space = Factory(:space, :course => @course)
      end
      context "member" do
        before do
          Factory(:user_environment_association, :environment => @environment,
                  :user => @member, :role => :member)
          Factory(:user_course_association, :course => @course,
                  :user => @member, :role => :member)
          Factory(:user_space_association, :space => @space,
                  :user => @member, :role => :member)
          @ability = Ability.new(@member)
        end

        it "cannot create a space" do
          @ability.should_not be_able_to(:create, Factory(:space,
                                                          :owner => @member,
                                                          :course => @course))
        end

        it "cannot destroy a space" do
          @ability.should_not be_able_to(:destroy, Factory(:space,
                                                           :owner => @member,
                                                           :course => @course))
        end

        it "can use students_endless on a space" do
          @ability.should be_able_to(:students_endless, @space)
        end

        it "can preview a space" do
          @ability.should be_able_to(:preview, @space)
        end

        it "can't see subject participation report" do
          @ability.should_not be_able_to(:subject_participation_report,
                                          @space)
        end

        it "can't see lecture participation report" do
          @ability.should_not be_able_to(:lecture_participation_report,
                                          @space)
        end

        it "can't see students participation report" do
          @ability.should_not be_able_to(:students_participation_report,
                                          @space)
        end
        it "cannot create a subject"
        it "cannot destroy any subject"
        it "cannot create a lecture"
        it "cannot destroy any lecture"
        it "cannot upload a file"
        it "cannot destroy any file"

        context "member posts on wall" do
          before do
            @activity = Factory(:activity,
                                :user => @member,
                                :statusable => @space)

            @answer_activity = Factory(:answer,
                                       :statusable => @activity,
                                       :in_response_to => @activity)

            @strange_activity = Factory(:activity, :statusable => @space)

            @strange_answer = Factory(:answer,
                                      :statusable => @strange_activity,
                                      :in_response_to => @strange_activity)
          end

          it "can creates a post" do
            @ability.should be_able_to(:create, @activity)
          end

          it "can destroy a post" do
            @ability.should be_able_to(:destroy, @activity)
          end

          it "can destroy answers from your posts" do
            @ability.should be_able_to(:destroy, @answer_activity)
          end

          it "can't destroy posts by other users" do
            @ability.should_not be_able_to(:destroy, @strange_activity)
          end

          it "can't destroy answers for posts by other users" do
            @ability.should_not be_able_to(:destroy, @strange_answer)
          end
        end
      end

      context "teacher" do
        before do
          Factory(:user_environment_association, :environment => @environment,
                  :user => @teacher, :role => :teacher)
          Factory(:user_course_association, :course => @course,
                  :user => @teacher, :role => :teacher)
          @space = Factory(:space, :owner => @teacher,
                           :course => @course)
          @ability = Ability.new(@teacher)
        end
        it "creates a space" do
          @ability.should be_able_to(:create, @space)
        end
        it "destroys his own space" do
          @ability.should be_able_to(:destroy, @space)
        end
        it "cannot destroy a strange space where he is a teacher" do
          environment1 = Factory(:environment)
          course1 = Factory.build(:course, :owner => environment1.owner,
                                  :environment => environment1)
          space1 = Factory.build(:space, :owner => @teacher,
                                 :course => course1)
          @ability.should_not be_able_to(:destroy, space1)
        end

        it "can't see subject participation report" do
          @ability.should be_able_to(:subject_participation_report,
                                      @space)
        end

        it "can't see lecture participation report" do
          @ability.should be_able_to(:lecture_participation_report,
                                      @space)
        end

        it "can't see studenst participation report" do
          @ability.should be_able_to(:students_participation_report,
                                      @space)
        end

        context "manage posts" do
          before do
            @activity = Factory(:activity,
                                :user => @member,
                                :statusable => @space)

            @answer = Factory(:answer,
                              :statusable => @activity,
                              :in_response_to => @activity)
          end

          it "teacher can destroy a posts by students" do
            @ability.should be_able_to(:destroy, @activity)
          end

          it "teacher can destroy a answers by students" do
            @ability.should be_able_to(:destroy, @answer)
          end
        end

        it "creates a subject"
        it "destroys any subject"
        it "creates a lecture"
        it "destroys any lecture"
        it "uploads a file"
        it "destroys any file"
        it "crates a post"
      end

      context "tutor" do
        before do
          Factory(:user_environment_association, :environment => @environment,
                  :user => @tutor, :role => :member)
          Factory(:user_course_association, :course => @course,
                  :user => @tutor, :role => :member)
          @ability = Ability.new(@tutor)
        end

        it "cannot create a space" do
          @ability.should_not be_able_to(:create, Factory(:space,
                                                          :owner => @tutor,
                                                          :course => @course))
        end
        it "cannot destroy a space" do
          @ability.should_not be_able_to(:destroy, Factory(:space,
                                                           :owner => @tutor,
                                                           :course => @course))
        end

        it "can't see subject participation report" do
          @ability.should_not be_able_to(:subject_participation_report,
                                          @space)
        end

        it "can't see lecture participation report" do
          @ability.should_not be_able_to(:lecture_participation_report,
                                          @space)
        end

        it "can't see students participation report" do
          @ability.should_not be_able_to(:students_participation_report,
                                          @space)
        end

        it "cannot create a subject"
        it "cannot destroy any subject"
        it "cannot create a lecture"
        it "cannot destroy any lecture"
        it "cannot upload a file"
        it "cannot destroy any file"
        it "crates a post"
      end

      context "environment admin" do
        before do
          @ability = Ability.new(@env_admin)
          @space = Factory(:space, :owner => @env_admin,
                          :course => @course)
        end

        it "creates a space" do
          @ability.should be_able_to(:create, @space)
        end
        it "destroys a space" do
          @ability.should be_able_to(:destroy, @space)
        end

        it "can see subject participation report" do
          @ability.should be_able_to(:subject_participation_report,
                                      @space)
        end

        it "can see lecture participation report" do
          @ability.should be_able_to(:lecture_participation_report,
                                      @space)
        end

        it "can see students participation report" do
          @ability.should be_able_to(:students_participation_report,
                                      @space)
        end

        context "manage posts" do
          before do
            @activity = Factory(:activity,
                                :user => @env_admin,
                                :statusable => @space)

            @answer = Factory(:answer,
                              :statusable => @activity,
                              :in_response_to => @activity)
          end
          it "teacher can destroy a posts by students" do
            @ability.should be_able_to(:destroy, @activity)
          end

          it "teacher can destroy a answers by students" do
            @ability.should be_able_to(:destroy, @answer)
          end
        end

        it "creates a subject"
        it "destroys any subject"
        it "creates a lecture"
        it "destroys any lecture"
        it "uploads a file"
        it "destroys any file"
        it "crates a post"
      end

      context "redu admin" do
        before do
          @ability = Ability.new(@redu_admin)
          @space = Factory(:space, :owner => @env_admin,
                          :course => @course)
        end
        it "creates a space" do
          space = Factory(:space, :owner => @redu_admin,
                          :course => @course)
          @ability.should be_able_to(:create, space)
        end
        it "destroys a space" do
          @ability.should be_able_to(:destroy, @space)
        end

        it "can see subject participation report" do
          @ability.should be_able_to(:subject_participation_report,
                                      @space)
        end

        it "can see lecture participation report" do
          @ability.should be_able_to(:lecture_participation_report,
                                      @space)
        end

        it "can see students participation report" do
          @ability.should be_able_to(:students_participation_report,
                                      @space)
        end

        it "creates a subject"
        it "destroys any subject"
        it "creates a lecture"
        it "destroys any lecture"
        it "uploads a file"
        it "destroys any file"
        it "crates a post"
      end

      context "strange" do
        before do
          @strange = Factory(:user)
          @ability = Ability.new(@strange)
        end

        it "can NOT preview a space" do
          space = Factory(:space, :course => @course)
          @ability.should_not be_able_to(:preview, space)
        end
      end
    end

    context "on subject" do
      before do
        @environment = Factory(:environment, :owner => @env_admin)
        @course = Factory(:course, :owner => @env_admin,
                          :environment => @environment)
        @space = Factory(:space, :owner => @env_admin, :course => @course)
        @subject = Factory(:subject, :owner => @env_admin, :space => @space)

        @lecture_page = Factory(:lecture, :subject => @subject,
                                :lectureable => Factory(:page))
        @lecture_canvas = Factory(:lecture, :subject => @subject,
                                :lectureable => Factory(:canvas))
        @lecture_exercise = Factory(:lecture, :subject => @subject,
                                    :lectureable => Factory(:complete_exercise))
        @lecture_seminar = Factory(:lecture, :subject => @subject,
                                   :lectureable => Factory(:seminar_youtube))
        mock_scribd_api
        @lecture_document = Factory(:lecture, :subject => @subject,
                                    :lectureable => Factory(:document))

        @course.join @teacher, Role[:teacher]
        @course.join @tutor, Role[:tutor]
        @course.join @member, Role[:member]
      end

      context "environment_admin" do
        before do
          @ability = Ability.new(@env_admin)
        end

        context "can manage all kinds of lectures" do
          it "(page)" do
            @ability.should be_able_to(:manage, @lecture_page)
          end
          it "(exercise)" do
            @ability.should be_able_to(:manage, @lecture_exercise)
          end
          it "(seminar)" do
            @ability.should be_able_to(:manage, @lecture_seminar)
          end
          it "(document)" do
            @ability.should be_able_to(:manage, @lecture_document)
          end
        end

        context "can update many kinds of lectures" do
          it "(page)" do
            @ability.should be_able_to(:update, @lecture_page)
          end

          it "(exercise)" do
            @ability.should be_able_to(:update, @lecture_exercise)
          end
        end

        context "can manage posts" do
          before do
            @activity = Factory(:activity,
                                :user => @member,
                                :statusable => @lecture_page)

            @answer = Factory(:answer,
                              :statusable => @activity,
                              :in_response_to => @activity)
          end

          it "teacher can destroy a posts by students" do
            @ability.should be_able_to(:destroy, @activity)
          end

          it "teacher can destroy a answers by students" do
            @ability.should be_able_to(:destroy, @answer)
          end
        end


        context "can NOT update many kinds of lectures" do
          it "(seminar)" do
            @ability.should_not be_able_to(:update, @lecture_seminar)
          end

          it "(document)" do
            @ability.should_not be_able_to(:update, @lecture_document)
          end

          it "(exercise) with that was already answered" do
            Factory(:finalized_result, :exercise => @lecture_exercise.lectureable)
            @lecture_exercise.lectureable.reload
            @ability.should_not be_able_to(:update, @lecture_exercise)
          end
        end
      end

      context "teacher" do
        before do
          @ability = Ability.new(@teacher)
        end

        context "can manage all kinds of lectures" do
          it "(page)" do
            @ability.should be_able_to(:manage, @lecture_page)
          end
          it "(exercise)" do
            @ability.should be_able_to(:manage, @lecture_exercise)
          end
          it "(seminar)" do
            @ability.should be_able_to(:manage, @lecture_seminar)
          end
          it "(document)" do
            @ability.should be_able_to(:manage, @lecture_document)
          end
          it "(canvas)" do
            @ability.should be_able_to(:manage, @lecture_canvas)
          end
        end

        context "can update many kinds of lectures" do
          it "(page)" do
            @ability.should be_able_to(:update, @lecture_page)
          end

          it "(exercise)" do
            @ability.should be_able_to(:update, @lecture_exercise)
          end
        end

        context "when lecture type canvas" do
          it "cannot update" do
            @ability.should_not be_able_to(:update, @lecture_canvas)
          end
        end

        context "can manage posts" do
          before do
            @activity = Factory(:activity,
                                :user => @member,
                                :statusable => @lecture_page)

            @answer = Factory(:answer,
                              :statusable => @activity,
                              :in_response_to => @activity)
          end

          it "teacher can destroy a posts by students" do
            @ability.should be_able_to(:destroy, @activity)
          end

          it "teacher can destroy a answers by students" do
            @ability.should be_able_to(:destroy, @answer)
          end
        end

        context "can NOT update many kinds of lectures" do
          it "(seminar)" do
            @ability.should_not be_able_to(:update, @lecture_seminar)
          end
          it "(document)" do
            @ability.should_not be_able_to(:update, @lecture_document)
          end
        end
      end

      context "tutor" do
        before do
          @ability = Ability.new(@tutor)
        end

        context "can NOT manage all kinds of lectures" do
          it "(page)" do
            @ability.should_not be_able_to(:manage, @lecture_page)
          end
          it "(exercise)" do
            @ability.should_not be_able_to(:manage, @lecture_exercise)
          end
          it "(seminar)" do
            @ability.should_not be_able_to(:manage, @lecture_seminar)
          end
          it "(document)" do
            @ability.should_not be_able_to(:manage, @lecture_document)
          end
        end

        context "can NOT update all kinds of lectures" do
          it "(page)" do
            @ability.should_not be_able_to(:update, @lecture_page)
          end
          it "(exercise)" do
            @ability.should_not be_able_to(:update, @lecture_exercise)
          end
          it "(seminar)" do
            @ability.should_not be_able_to(:update, @lecture_seminar)
          end
          it "(document)" do
            @ability.should_not be_able_to(:update, @lecture_document)
          end
        end
      end

      context "member" do
        before do
          @ability = Ability.new(@member)
        end

        context "can NOT manage all kinds of lectures" do
          it "(page)" do
            @ability.should_not be_able_to(:manage, @lecture_page)
          end
          it "(exercise)" do
            @ability.should_not be_able_to(:manage, @lecture_exercise)
          end
          it "(seminar)" do
            @ability.should_not be_able_to(:manage, @lecture_seminar)
          end
          it "(document)" do
            @ability.should_not be_able_to(:manage, @lecture_document)
          end
        end

        context "member posts on wall" do
          before do
            @activity = Factory(:activity,
                                :user => @member,
                                :statusable => @lecture_document)

            @help = Factory(:help,
                            :user => @member,
                            :statusable => @lecture_document)

            @answer_activity = Factory(:answer,
                                       :statusable => @activity,
                                       :in_response_to => @activity)

            @answer_help = Factory(:answer,
                                   :statusable => @help,
                                   :in_response_to => @help)


            @strange_activity = Factory(:activity,
                                        :statusable => @lecture_document)

            @strange_help = Factory(:help,
                                    :statusable => @lecture_document)

            @strange_answer = Factory(:answer,
                                      :statusable => @strange_activity,
                                      :in_response_to => @strange_activity)
          end

          it "can creates a post" do
            @ability.should be_able_to(:create, @activity)
            @ability.should be_able_to(:create, @help)
          end

          it "can destroy a post" do
            @ability.should be_able_to(:destroy, @activity)
            @ability.should be_able_to(:destroy, @help)
          end

          it "can destroy answers from your posts" do
            @ability.should be_able_to(:destroy, @answer_activity)
            @ability.should be_able_to(:destroy, @answer_help)
          end

          it "can't destroy posts by other users" do
            @ability.should_not be_able_to(:destroy, @strange_activity)
            @ability.should_not be_able_to(:destroy, @strange_help)
          end

          it "can't destroy answers for posts by other users" do
            @ability.should_not be_able_to(:destroy, @strange_answer)
          end
        end

        context "can NOT update all kinds of lectures" do
          it "(page)" do
            @ability.should_not be_able_to(:update, @lecture_page)
          end
          it "(exercise)" do
            @ability.should_not be_able_to(:update, @lecture_exercise)
          end
          it "(seminar)" do
            @ability.should_not be_able_to(:update, @lecture_seminar)
          end
          it "(document)" do
            @ability.should_not be_able_to(:update, @lecture_document)
          end
        end
      end
    end

    context "on plans" do
      context "on any plan" do
        before do
          @plan = Factory(:plan)
          @ability = Ability.new(@plan.user)
        end

        context "blocked" do
          before do
            @plan.update_attribute(:state, "blocked")
          end

          it "can NOT be migrated" do
            @ability.should_not be_able_to(:migrate, @plan)
          end
        end

        context "migrated" do
          before do
            @plan.update_attribute(:state, "migrated")
          end

          it "can not be migrated" do
            @ability.should_not be_able_to(:migrate, @plan)
          end
        end
      end

      context "on package_plan" do
        before do
          @package_plan = Factory(:active_package_plan)
          @invoice = Factory(:package_invoice, :plan => @package_plan)
        end

        context "the owner" do
          before do
            @ability = Ability.new(@package_plan.user)
          end

          it "read its own package_plan" do
            @ability.should be_able_to(:read, @package_plan)
          end

          it "manages its own package_plan" do
            @ability.should be_able_to(:manage, @package_plan)
          end

          it "migrates its own package_plan" do
            @ability.should be_able_to(:migrate, @package_plan)
          end

          it "reads package_plan's invoice" do
            @ability.should be_able_to(:read, @invoice)
          end

          it "manages package_plan's invoice" do
            @ability.should be_able_to(:manage, @invoice)
          end

          it "can pay package_plan's invoice with pagseguro" do
            @ability.should be_able_to(:pay_with_pagseguro, @invoice)
          end

          it "can NOT pay paid package_plan's invoice with pagseguro" do
            @invoice.update_attribute(:state, "paid")
            @ability.should_not be_able_to(:pay_with_pagseguro, @invoice)
          end
        end

        context "the strange" do
          before do
            strange = Factory(:user)
            @ability = Ability.new(strange)
          end

          it "can NOT read others package_plans" do
            @ability.should_not be_able_to(:read, @package_plan)
          end

          it "can NOT manage others package_plans" do
            @ability.should_not be_able_to(:manage, @package_plan)
          end

          it "can NOT migrate others package_plans" do
            @ability.should_not be_able_to(:migrate, @package_plan)
          end

          it "can NOT read others package_plan's invoice" do
            @ability.should_not be_able_to(:read, @invoice)
          end

          it "can NOT manage others package_plan's invoice" do
            @ability.should_not be_able_to(:manage, @invoice)
          end
        end
      end

      context "on licensed_plan" do
        before do
          @licensed_plan = Factory(:active_licensed_plan)
          @invoice = Factory(:licensed_invoice, :plan => @licensed_plan)
          @invoice.update_attribute(:state, "pending")
        end

        context "the owner" do
          before do
            @ability = Ability.new(@licensed_plan.user)
          end

          it "read its own licensed_plan" do
            @ability.should be_able_to(:read, @licensed_plan)
          end

          it "manages its own licensed_plan" do
            @ability.should be_able_to(:manage, @licensed_plan)
          end

          it "migrates its own licensed_plan" do
            @ability.should be_able_to(:migrate, @licensed_plan)
          end

          it "reads licensed_plan's invoice" do
            @ability.should be_able_to(:read, @invoice)
          end

          it "manages licensed_plan's invoice" do
            @ability.should be_able_to(:manage, @invoice)
          end

          it "can NOT pay licensed_plan's invoice" do
            @ability.should_not be_able_to(:pay, @invoice)
          end
        end

        context "the strange" do
          before do
            strange = Factory(:user)
            @ability = Ability.new(strange)
          end

          it "can NOT read others licensed_plans" do
            @ability.should_not be_able_to(:read, @licensed_plan)
          end

          it "can NOT manage others licensed_plans" do
            @ability.should_not be_able_to(:manage, @licensed_plan)
          end

          it "can NOT migrate others licensed_plans" do
            @ability.should_not be_able_to(:migrate, @licensed_plan)
          end

          it "can NOT read others licensed_plan's invoice" do
            @ability.should_not be_able_to(:read, @invoice)
          end

          it "can NOT manage others licensed_plan's invoice" do
            @ability.should_not be_able_to(:manage, @invoice)
          end
        end

        context "the partner admin" do
          before do
            partner_env_assoc = Factory(:partner_environment_association)
            partner = partner_env_assoc.partner
            environment = partner_env_assoc.environment

            partner_admin = Factory(:user)
            partner.add_collaborator partner_admin
            @ability = Ability.new(partner_admin)

            @licensed_plan = Factory(:active_licensed_plan,
                                     :billable => environment)
            @invoice = Factory(:licensed_invoice, :plan => @licensed_plan)
            @invoice.pend!
          end

          it "can read partner licensed_plans" do
            @ability.should be_able_to(:read, @licensed_plan)
          end

          it "can read partner licensed_plans of dead billable" do
            @licensed_plan.billable.audit_billable_and_destroy
            @ability.should be_able_to(:read, @licensed_plan.reload)
          end

          it "can manage partner licensed_plans" do
            @ability.should be_able_to(:manage, @licensed_plan)
          end

          it "can migrate partner licensed_plans" do
            @ability.should be_able_to(:migrate, @licensed_plan)
          end

          it "can read partner licensed_plan's invoice" do
            @ability.should be_able_to(:read, @invoice)
          end

          it "can manage partner licensed_plan's invoice" do
            @ability.should be_able_to(:manage, @invoice)
          end

          it "can NOT pay licensed_plan's invoice" do
            @ability.should_not be_able_to(:pay, @invoice)
          end
        end

        context "the redu admin" do
          before do
            redu_admin = Factory(:user, :role => Role[:admin])
            @ability = Ability.new(redu_admin)
          end

          it "can pay licensed_plan's invoice" do
            @ability.should be_able_to(:pay, @invoice)
          end

          it "can NOT pay a non pending invoice" do
            @invoice.pay!
            @ability.should_not be_able_to(:pay, @invoice.reload)
          end

          it "can pay a overdue invoice" do
            @invoice.overdue!
            @ability.should be_able_to(:pay, @invoice.reload)
          end

          it "can manage partner licensed_plans of dead billable" do
            @licensed_plan.billable.audit_billable_and_destroy
            @ability.should be_able_to(:manage, @licensed_plan)
          end

          it "can migrate a blocked or migrated plan" do
            @plan = Factory(:plan)
            @plan.update_attribute(:state, "blocked")
            @ability.should be_able_to(:migrate, @plan)

            @plan.update_attribute(:state, "blocked")
            @ability.should be_able_to(:migrate, @plan)
          end
        end
      end
    end

  end

  context "on user -" do
    before do
      @user = Factory(:user)
      @user_ability = Ability.new(@user)
    end

    context "pusher channels" do
      before do
        @stranger = Factory(:user)
        @friend = Factory(:user)

        friendship, status = @user.be_friends_with(@friend)
        friendship.accept!
      end

      it "can auth a channel" do
        @user_ability.should be_able_to(:auth, @user)
      end

      it "can NOT auth a contact channel" do
        @user_ability.should_not be_able_to(:auth, @friend)
      end

      it "can subscribe a contact channel" do
        @user_ability.should be_able_to(:subscribe_channel, @friend)
      end

      it "can NOT subscribe a stranger channel" do
        @user_ability.should_not be_able_to(:subscribe_channel, @stranger)
      end

      context "when chatting" do
        before do
          course = Factory(:course)
          @colleague = Factory(:user)
          @teacher = Factory(:user)
          course.join(@user)
          course.join(@colleague)
          course.join(@teacher, Role[:teacher])
        end

        it "can send a message to a friend" do
          @user_ability.should be_able_to(:send_chat_message, @friend)
        end

        it "can send a message to a teacher" do
          @user_ability.should be_able_to(:send_chat_message, @teacher)
        end

        it "can NOT send a message to a colleague" do
          @user_ability.should_not be_able_to(:send_chat_message, @colleague)
        end

        it "can NOT send a message to a stranger" do
          @user_ability.should_not be_able_to(:send_chat_message, @stranger)
        end
      end

      context "when requesting last chat messages" do
        before do
          course = Factory(:course)
          @colleague = Factory(:user)
          @teacher = Factory(:user)
          course.join(@user)
          course.join(@colleague)
          course.join(@teacher, Role[:teacher])
        end

        it "can request his messages with a teacher" do
          @user_ability.should be_able_to(:last_messages_with, @teacher)
        end

        it "can NOT request his messages with a colleague" do
          @user_ability.should_not be_able_to(:last_messages_with, @colleague)
        end

        it "can NOT request his messages with a stranger" do
          @user_ability.should_not be_able_to(:last_messages_with, @stranger)
        end
      end
    end

    context "when friends" do
      before do
        @my_friend = Factory(:user)
        @my_friend_ability = Ability.new(@my_friend)

        friendship, status = @user.be_friends_with(@my_friend)
        friendship.accept!
      end

      it "should read each other" do
        @user_ability.should be_able_to(:read, @my_friend)
        @my_friend_ability.should be_able_to(:read, @user)
      end

      it "should not manage each other" do
        @user_ability.should_not be_able_to(:manage, @my_friend)
        @my_friend_ability.should_not be_able_to(:manage, @user)
      end
    end

    context "when user privacy" do
      context "let everyone see his statuses" do
        before do
          @user.settings.view_mural = Privacy[:public]
        end

        context "and they are friends," do
          before do
            @my_friend = Factory(:user)
            @my_friend_ability = Ability.new(@my_friend)

            friendship, status = @user.be_friends_with(@my_friend)
            friendship.accept!
          end

          it "a friend can view user's statuses" do
            @my_friend_ability.should be_able_to(:view_mural, @user)
          end
        end

        context "and they are NOT friends," do
          before do
            @someone = Factory(:user)
            @someone_ability = Ability.new(@someone)
          end

          it "someone can view user's statuses" do
            @someone_ability.should be_able_to(:view_mural, @user)
          end
        end
      end

      context "let ONLY friends see his statuses" do
        before do
          @user.settings.view_mural = Privacy[:friends]
        end

        context "and they are friends," do
          before do
            @my_friend = Factory(:user)
            @my_friend_ability = Ability.new(@my_friend)

            friendship, status = @user.be_friends_with(@my_friend)
            friendship.accept!
          end

          it "a friend can view user's statuses" do
            @my_friend_ability.should be_able_to(:view_mural, @user)
          end
        end

        context "and they are NOT friends," do
          before do
            @someone = Factory(:user)
            @someone_ability = Ability.new(@someone)
          end

          it "someone can NOT view user's statuses" do
            @someone_ability.should_not be_able_to(:view_mural, @user)
          end
        end
      end
    end

    context "when experiences" do
      before do
        @user_experience = Factory(:experience, :user => @user)
        @other_experience = Factory(:experience)
      end
      it "manages its own experiences" do
        @user_ability.should be_able_to(:manage, @user_experience)
      end

      it "can NOT manage other experiences" do
        @user_ability.should_not be_able_to(:manage, @other_experience)
      end
    end

    context "when educations" do
      before do
        @user_education = Factory(:education, :user => @user)
        @other_education = Factory(:education)
      end
      it "manages its own educations" do
        @user_ability.should be_able_to(:manage, @user_education)
      end

      it "can NOT manage other educations" do
        @user_ability.should_not be_able_to(:manage, @other_education)
      end
    end

    it "manages itself" do
      @user_ability.should be_able_to(:manage, @user)
    end

    context "manages its own statuses" do
      it "when activy" do
        status = Factory(:activity, :user => @user)
        @user_ability.should be_able_to(:manage, status)
      end

      it "when answer" do
        status = Factory(:answer, :user => @user)
        @user_ability.should be_able_to(:manage, status)
      end

      it "when help" do
        status = Factory(:help, :user => @user)
        @user_ability.should be_able_to(:manage, status)
      end
    end

    context "when destroying user" do
      before do
        @other = Factory(:user)
      end
      it "can NOT destroy others user" do
        @user_ability.should_not be_able_to(:destroy, @other)
      end

      it "can destroy its own user" do
        @user_ability.should be_able_to(:destroy, @user)
      end
    end

    context "when seeing my wall" do
      before do
        @other = Factory(:user)
      end

      it "others can NOT access my wall" do
        @user_ability.should_not be_able_to(:my_wall, @other)
      end

      it "can access my wall" do
        @user_ability.should be_able_to(:my_wall, @user)
      end
    end

    context "when manage invitations" do
      before do
        @bastard = Factory(:user,
                           :first_name => 'Jhon',
                           :last_name => 'Snow')
        @bastard_ability = Ability.new(@bastard)
        @bastard_invitation = Invitation.invite(:user => @bastard,
                                                :hostable => @bastard,
                                                :email => 'mail@teste.com')

        @my_invitation = Invitation.invite(:user => @user,
                                           :hostable => @user,
                                           :email => 'mail@teste.com')
      end

      it "others can't manage my invitations" do
        @bastard_ability.should_not be_able_to(:manage, @my_invitation)
      end

      it "can destroy invitation" do
        @user_ability.should be_able_to(:destroy_invitations, @my_invitation)
      end

      it "can resend invitation email" do
        @user_ability.should be_able_to(:resend_email, @my_invitation)
      end
    end
  end

  context "on PartnerEnvironmentAssociation" do
    before do
      @partner = Factory(:partner)

      3.times do
        course = Factory(:course)
        Factory(:partner_environment_association,
                :environment => course.environment,
                :partner => @partner)
      end

      @peas = @partner.partner_environment_associations
    end

    context "the collaborator" do
      before do
        @collaborator = Factory(:user)
        @user_ability = Ability.new(@collaborator)
        @partner.add_collaborator(@collaborator)
      end

      it "can manage" do
        @peas.each do |association|
          @user_ability.should be_able_to(:manage, association)
        end
      end
    end

    context "the collaborator of other partner" do
      before do
        @collaborator = Factory(:user)
        @user_ability = Ability.new(@collaborator)
        @another = Factory(:partner)
        3.times do
          course = Factory(:course)
          Factory(:partner_environment_association,
                  :environment => course.environment,
                  :partner => @another)
        end
        @another.add_collaborator(@collaborator)
      end

      it "cannot manage" do
        @peas.each do |association|
          @user_ability.should_not be_able_to(:manage, association)
        end
      end

      it "cannot read" do
        @peas.each do |association|
          @user_ability.should_not be_able_to(:read, association)
        end
      end
    end

    context "the outsider" do
      before do
        @user = Factory(:user)
        @user_ability = Ability.new(@user)
      end

      it "cannot manage" do
        @peas.each do |association|
          @user_ability.should_not be_able_to(:manage, association)
        end
      end
    end
  end

  context "on Partner" do
    before do
      @partner = Factory(:partner)
    end
    context "all common users" do
      before do
        @user = Factory(:user)
        @user_ability = Ability.new(@user)
      end

      it "cannot manage" do
        @user_ability.should_not be_able_to(:manage, @partner)
      end

      it "cannot view" do
        @user_ability.should_not be_able_to(:read, @partner)
      end

      it "can contact" do
        @user_ability.should be_able_to(:contact, @partner)
      end

      it "cannot view all partners" do
        @user_ability.should_not be_able_to(:index, Partner)
      end
    end

    context "the collbarator" do
      before do
        @user = Factory(:user)
        @partner.add_collaborator(@user)

        @user_ability = Ability.new(@user)
      end

      it "can view" do
        @user_ability.should be_able_to(:read, @partner)
      end

      it "can manage" do
        @user_ability.should be_able_to(:manage, @partner)
      end

      it "cannot view all partners" do
        @user_ability.should_not be_able_to(:index, Partner)
      end
    end

    context "the redu admin" do
      before do
        @redu_admin = Factory(:user, :role => Role[:admin])
        @redu_admin_ability = Ability.new(@redu_admin)
      end

      it "can view" do
        @redu_admin_ability.should be_able_to(:read, @partner)
      end

      it "can manage" do
        @redu_admin_ability.should be_able_to(:manage, @partner)
      end

      it "cannot view all partners" do
        @redu_admin_ability.should be_able_to(:index, Partner)
      end
    end
  end

  context "on Result" do
    before do
      @space = Factory(:space)
      @subject = Factory(:subject, :owner => @space.owner,
                         :space => @space, :finalized => true,
                         :visible => true)
      @lecture = Factory(:lecture, :subject => @subject, :owner => @space.owner,
                         :lectureable => Factory(:complete_exercise))
      @exercise = @lecture.lectureable

      @member = Factory(:user)
      @other_member = Factory(:user)
      @teacher = Factory(:user)
      @tutor = Factory(:user)
      @external = Factory(:user)

      @space.course.join(@member)
      @space.course.join(@other_member)
      @space.course.join(@teacher, Role[:teacher])
      @space.course.join(@tutor, Role[:tutor])
    end

    context "when teacher" do
      let(:ability) { Ability.new(@teacher) }
      let(:result) { @exercise.start_for(@member) }

      it "should be able to manage members results" do
        ability.should be_able_to(:manage, result)
      end

      it "should not be able to manage results from another space" do
        space = Factory(:space)
        subj = Factory(:subject, :owner => space.owner,
                       :space => space, :finalized => true,
                       :visible => true)
        lecture = Factory(:lecture, :subject => subj, :owner => space.owner,
                          :lectureable => Factory(:complete_exercise))
        exercise = lecture.lectureable
        space.course.join(@member)
        new_result = exercise.start_for(@member)

        ability.should_not be_able_to(:manage, new_result)
      end
    end

    context "when member" do
      let(:ability) { Ability.new(@member) }
      let(:own_result) { @exercise.start_for(@member) }
      let(:other_result) { @exercise.start_for(@other_member) }

      it "should be able to read own result" do
        ability.should be_able_to(:read, own_result)
      end

      it "should be able to create" do
        ability.should be_able_to(:create, Result)
      end

      it "should be able to update" do
        ability.should be_able_to(:update, own_result)
      end

      it "should not be able to update if finalized" do
        @exercise.start_for(@member)
        result = @exercise.finalize_for(@member)
        ability.should_not be_able_to(:update, result)
      end

      it "should not be able to update a strange result" do
        ability.should_not be_able_to(:update, other_result)
      end

      it "should not be able to read a strange result" do
        ability.should_not be_able_to(:read, other_result)
      end

      it "should not be able to read the another member result" do
        ability.should_not be_able_to(:read, other_result)
      end
    end

    context "when strange" do
      let(:ability) { Ability.new(@strange) }
      let(:member_result) { @exercise.start_for(@member) }

      it "should not be able to read" do
        ability.should_not be_able_to(:read, member_result)
      end
    end
  end

  context "on Question" do
   before do
      @space = Factory(:space)
      @subject = Factory(:subject, :owner => @space.owner,
                         :space => @space, :finalized => true,
                         :visible => true)
      @lecture = Factory(:lecture, :subject => @subject, :owner => @space.owner,
                         :lectureable => Factory(:complete_exercise))
      @exercise = @lecture.lectureable
      @questions = @exercise.questions

      @member = Factory(:user)
      @other_member = Factory(:user)
      @teacher = Factory(:user)
      @tutor = Factory(:user)
      @external = Factory(:user)

      @space.course.join(@member)
      @space.course.join(@other_member)
      @space.course.join(@teacher, Role[:teacher])
      @space.course.join(@tutor, Role[:tutor])
    end

    context "when member" do
      let(:ability) { Ability.new(@member) }
      it "should be able to read" do
        ability.should be_able_to(:read, @questions.first)
      end
    end

    context "when teacher" do
      let(:ability) { Ability.new(@teacher) }
      it "should be able to read" do
        ability.should be_able_to(:read, @questions.first)
      end
    end

    context "when strange" do
      let(:ability) { Ability.new(@strange) }

      it "should not be able to read" do
        ability.should_not be_able_to(:read, @questions.first)
      end
    end
  end

  context "on Exercise" do
   before do
      @space = Factory(:space)
      @subject = Factory(:subject, :owner => @space.owner,
                         :space => @space, :finalized => true,
                         :visible => true)
      @lecture = Factory(:lecture, :subject => @subject, :owner => @space.owner,
                         :lectureable => Factory(:complete_exercise))
      @exercise = @lecture.lectureable
      @questions = @exercise.questions

      @member = Factory(:user)
      @other_member = Factory(:user)
      @teacher = Factory(:user)
      @tutor = Factory(:user)
      @external = Factory(:user)

      @space.course.join(@member)
      @space.course.join(@other_member)
      @space.course.join(@teacher, Role[:teacher])
      @space.course.join(@tutor, Role[:tutor])
    end

   context "when teacher" do
     let(:ability) { Ability.new(@teacher) }
     it "should not be able to update if there are finalized results" do
       @exercise.start_for(@member)
       @exercise.finalize_for(@member)
       ability.should_not be_able_to(:manage, @exercise)
     end

     it "should be able to update if there arent finalized results" do
       @exercise.start_for(@member)
       ability.should be_able_to(:manage, @lecture)
     end

     it "should be able to update if there arent results at all" do
       ability.should be_able_to(:manage, @lecture)
     end
   end
  end

  context "on Canvas" do
    before do
      env = Factory(:complete_environment)
      @course = env.courses.first
      space = @course.spaces.first
      sub = Factory(:subject, :owner => space.owner,
                    :space => space, :finalized => true,
                    :visible => true)

      @canvas = Factory(:canvas, :user => @course.owner)
      Factory(:lecture, :subject => sub,
              :owner => space.owner, :lectureable => @canvas)
    end

    let(:user) { Factory(:user) }
    let(:ability) { Ability.new(user) }

    context "when member" do
      before do
        @course.join(user)
      end

      it "should be able to read" do
        ability.should be_able_to :read, @canvas
      end
    end

    context "when outsider" do
      it "should not be able to read" do
        ability.should_not be_able_to :read, @canvas
      end
    end
  end

  context "client applications" do
    let(:user) { Factory(:user) }
    let(:client_application) { ClientApplication.new }
    let(:ability) { Ability.new(user) }
    let(:redu_admin) {Factory(:user, :role => :admin)}
    let(:admin_abilty) {Ability.new(redu_admin)}
    context "user" do
      it "should not be able to manage" do
        ability.should_not be_able_to :manage, client_application
      end
    end

    context "admin" do
      it "should be able to manage" do
        admin_abilty.should be_able_to :manage, client_application
      end
    end
  end

  context "when searching" do

    context "logged user" do
      let(:user) { Factory(:user) }

      it "should be able to perform searches" do
        Ability.new(user).should be_able_to :search, :all
      end
    end

    context "not logged user" do
      let(:user) { nil }

      it "should not be able to perform searches" do
        Ability.new(user).should_not be_able_to :search, :all
      end
    end
  end

end
