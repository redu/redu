require 'spec_helper'
require 'authlogic/test_case'

describe CoursesController do
  context "when creating a course for an existing environment" do
    before do
      @user = Factory(:user)
      activate_authlogic
      UserSession.create @user

      @environment = Factory(:environment, :owner => @user)

      @params = {:course =>
        { :name => "Redu", :workload => 12,
          :tag_list => "minhas, tags, exemplo, aula, teste",
          :path => "redu", :subscription_type => 1,
          :description => "Lorem ipsum dolor sit amet, consectetur magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation
        ullamco laboris nisi ut aliquip ex ea commodo."},
        :plan => "free",
        :environment_id => @environment.id,
        :locale => "pt-BR" }
    end

    context "POST create" do
      before do
        post :create, @params
      end

      it "should create the course" do
        assigns[:course].should_not be_nil
        assigns[:course].should be_valid
      end

      it "should create the plan" do
        assigns[:course].plan.should_not be_nil
      end

      it "should assign the plan user to current_user" do
        assigns[:course].plan.user.should == @user
      end

      it "should create the quota and computes it" do
        assigns[:course].quota.should_not be_nil
      end
    end

    context "POST create - testing plans" do
      it "should be a professor_lite plan" do
        @params[:plan] = "professor_lite"
        post :create, @params
        assigns[:plan].name.should == "Professor Lite"
      end

      it "should be a professor standard plan" do
        @params[:plan] = "professor_standard"
        post :create, @params
        assigns[:plan].name.should == "Professor Standard"
      end

      it "should be a professor plus plan" do
        @params[:plan] = "professor_plus"
        post :create, @params
        assigns[:plan].name.should == "Professor Plus"
      end

      it "should be a empresas lite plan" do
        @params[:plan] = "empresas_lite"
        post :create, @params
        assigns[:plan].name.should == "Empresa Lite"
      end

      it "should be a empresas standard plan" do
        @params[:plan] = "empresas_standard"
        post :create, @params
        assigns[:plan].name.should == "Empresa Standard"
      end

      it "should be a empresa plus plan" do
        @params[:plan] = "empresas_plus"
        post :create, @params
        assigns[:plan].name.should == "Empresa Plus"
      end

      it "should be a intituicao plus plan " do
        @params[:plan] = "instituicao_plus"
        post :create, @params
        assigns[:plan].name.should == "Instituição Plus"
      end

      it "should be a instituicao lite plan" do
        @params[:plan] = "instituicao_lite"
        post :create, @params
        assigns[:plan].name.should == "Instituição Lite"
      end

      it "should be a instituicao standard plan" do
        @params[:plan] = "instituicao_standard"
        post :create, @params
        assigns[:plan].name.should == "Instituição Standard"
      end
    end
  end

  context "when updating a couse" do
    context "POST update - updating a subscription_type to 1" do
      before do
        @user = Factory(:user)
        activate_authlogic
        UserSession.create @user

        @environment = Factory(:environment, :owner => @user)

        @course = Factory(:course,:environment => @environment, :owner => @user,
                          :subscription_type => 2)
        @users = 5.times.inject([]) { |res, i| res << Factory(:user) }
        @course.join(@users[0])
        @course.join(@users[1])
        @course.join(@users[2])
        @course.join(@users[3])
        @course.join(@users[4])

        UserSession.create @user
        @params = {:course => { :subscription_type => "1" },
          :id => @course.id,:environment_id => @course.environment.id,
          :locale => "pt-BR"}
        post :update, @params
      end

      it "should update a course" do
        assigns[:course].should_not be_nil
        assigns[:course].should be_valid
      end

      it "should create associations with all members that are waiting" do
        @course.approved_users.to_set.should == (@users << @user).to_set
        @course.pending_users.should == []
      end
    end
  end

  context "when moderating a course" do
    before do
      @user = Factory(:user)
      activate_authlogic
      UserSession.create @user

      @environment = Factory(:environment, :owner => @user)

      @course = Factory(:course,:environment => @environment,
                        :owner => @user,
                        :subscription_type => 2)

      plan = Factory(:plan, :billable => @course,
                     :user => @course.owner)
      @course.create_quota

      @space = Factory(:space, :course => @course, :owner => @user)
      @users = 5.times.inject([]) { |res, i| res << Factory(:user) }
      @course.join(@users[0])
      @course.join(@users[1])
      @course.join(@users[2])
      @course.join(@users[3])
      @course.join(@users[4])

      UserSession.create @user
    end

    context "POST - rejecting members" do
      before do
        @params = { :member => { @users[1].id.to_s => "reject",
                                 @users[2].id.to_s => "reject",
                                 @users[3].id.to_s => "approve"},
                    :id => @course.id, :environment_id => @environment.id,
                    :locale => "pt-BR"}
        post :moderate_members_requests, @params
      end

      it "should assign course" do
        assigns[:course].should_not be_nil
        assigns[:course].should be_valid
      end

      it "should destroy association" do
        @users[1].get_association_with(@course).should be_nil
        @users[2].get_association_with(@course).should be_nil
        @users[1].get_association_with(@course.environment).should be_nil
        @users[2].get_association_with(@course.environment).should be_nil
        @users[1].get_association_with(@space).should be_nil
        @users[2].get_association_with(@space).should be_nil
        @course.approved_users.to_set.should == [@user, @users[3]].to_set
      end
    end

    context "POST - accepting member" do
      before do
        @params = { :member => { @users[1].id.to_s => "approve",
                                 @users[2].id.to_s => "approve"},
                    :id => @course.id, :environment_id => @environment.id,
                    :locale => "pt-BR"}
        post :moderate_members_requests, @params
      end

      it "should assign course" do
        assigns[:course].should_not be_nil
        assigns[:course].should be_valid
      end

      it "should approve association" do
        @course.approved_users.to_set.should == [@users[1], @users[2], @user].to_set
      end

      it "should create environment and space associations" do
        @course.environment.users.to_set.should == [@users[1], @users[2], @user].to_set
        @space.users.to_set.should == [@users[1], @users[2], @user].to_set
      end
    end

  end

  context "when viewing existent courses list" do
    before do
      @courses = (1..10).collect { Factory(:course) }
      @audiences = (1..5).collect { Factory(:audience) }

      @courses[0..3].each_with_index do |c, i|
        c.audiences << @audiences[i] << @audiences[i+1]
      end

      @courses[4..7].each_with_index do |c, i|
        c.audiences << @audiences.reverse[i] << @audiences.reverse[i+1]
      end
    end

    context "GET index" do
      before do
        get :index, :locale => 'pt-BR'
      end

      it "should assign all courses" do
        assigns[:courses].should_not be_nil
        assigns[:courses].to_set.
          should == Course.published.all(:limit => 10).to_set
      end

      it "should render courses/new/index" do
        response.should render_template('courses/new/index')
      end
    end

    context "where the user is" do
      before  do
        User.maintain_sessions = false
        @user = Factory(:user)
        activate_authlogic
        UserSession.create @user

        @courses[0].join @user
        @courses[5].join @user
        @courses[1..3].each { |c| c.join @user, Role[:tutor] }
        @courses[6].join @user, Role[:teacher]
        @courses[7].join @user, Role[:environment_admin]

      end

      context "student" do
        before do
          get :index, :locale => 'pt-BR', :role => 'student'
        end

        it "should assign all these courses" do
          assigns[:courses].should_not be_nil
          assigns[:courses].to_set.should == [@courses[0], @courses[5]].to_set
        end

        it "should render courses/new/index" do
          response.should render_template('courses/new/index')
        end
      end

      context "tutor" do
        before do
          get :index, :locale => 'pt-BR', :role => 'tutor'
        end

        it "should assign all these courses" do
          assigns[:courses].should_not be_nil
          assigns[:courses].to_set.should == @courses[1..3].to_set
        end

        it "should render courses/new/index" do
          response.should render_template('courses/new/index')
        end
      end

      context "teacher" do
        before do
          get :index, :locale => 'pt-BR', :role => 'teacher'
        end

        it "should assign all these courses" do
          assigns[:courses].should_not be_nil
          assigns[:courses].to_set.should == [@courses[6]].to_set
        end

        it "should render courses/new/index" do
          response.should render_template('courses/new/index')
        end
      end

      context "administrator" do
        before do
          get :index, :locale => 'pt-BR', :role => 'administrator'
        end

        it "should assign all these courses" do
          assigns[:courses].should_not be_nil
          assigns[:courses].to_set.should == [@courses[7]].to_set
        end

        it "should render courses/new/index" do
          response.should render_template('courses/new/index')
        end
      end
    end

    context "GET index with js format" do
      before do
        get :index, :locale => 'pt-BR', :format =>'js'
      end

      it "should assign all courses" do
        assigns[:courses].should_not be_nil
        assigns[:courses].to_set.
          should == Course.published.all(:limit => 10).to_set
      end

      it "should render courses/new/index" do
        response.should render_template('courses/new/index')
      end
    end

    context "POST index" do
      context "with specified audiences" do
        before do
          post :index, :locale => 'pt-BR',
            :audiences_ids => [@audiences[0].id, @audiences[3].id]
        end

        it "should assign all courses with one of specified audiences" do
          assigns[:courses].should_not be_nil
          assigns[:courses].to_set.should == Course.
            with_audiences([@audiences[0].id, @audiences[3].id]).to_set
        end
      end

      context "with specified keyword" do
        before  do
          @c1 = Factory(:course, :name => 'keyword')
          @c2 = Factory(:course, :name => 'another key')
          @c3 = Factory(:course, :name => 'key 2')
          post :index, :locale => 'pt-BR', :search => 'key'
        end

        it "should assign all courses with name LIKE the keyword" do
          assigns[:courses].should_not be_nil
          assigns[:courses].to_set.should == [@c1, @c2, @c3].to_set
        end
      end

      context "with specified audiences AND with specified keyword" do
        before  do
          @c1 = Factory(:course, :name => 'keyword')
          @c2 = Factory(:course, :name => 'another key')
          @c3 = Factory(:course, :name => 'key 2')
          @a1 = Factory(:audience)
          @a2 = Factory(:audience)

          @c1.audiences << @a1
          @c2.audiences << @a1 << @a2
          post :index, :locale => 'pt-BR', :search => 'key',
            :audiences_ids => [@a1.id, @a2.id]
        end

        it "should assign all courses with one of specified audience AND name LIKE the keyword" do
          assigns[:courses].should_not be_nil
          assigns[:courses].to_set.should == [@c1, @c2].to_set
        end
      end
    end
  end

  context "when unjoin from a course (POST unjoin)" do
    before do
      @owner = Factory(:user)

      @environment = Factory(:environment, :owner => @owner)

      @course = Factory(:course,:environment => @environment, :owner => @owner)
      @spaces = (1..2).collect { Factory(:space, :course => @course,
                                         :owner => @owner)}
      @subjects = []
      @spaces.each do |s|
        @subjects << Factory(:subject, :space => s, :owner => @owner,
                :finalized => true)
      end

      @user = Factory(:user)
      @course.join @user
      @subjects.each { |sub| sub.enroll @user }
      activate_authlogic
      UserSession.create @user

      @params = { :locale => 'pt-BR', :environment_id => @environment.id,
        :id => @course.id }
      post :unjoin, @params
    end

    it "assigns course" do
    end

    it "removes the user from itself" do
      @course.users.should_not include(@user)
    end
    it "removes the user from all spaces" do
      @spaces.collect { |s| s.users.should_not include(@user) }
    end
    it "removes the user from all enrolled subjects" do
      @subjects.collect { |s| s.members.should_not include(@user) }
    end

  end

  context "when responding a course invitation" do
    before do
      @owner = Factory(:user)
      @environment = Factory(:environment, :owner => @owner)
      @course = Factory(:course,:environment => @environment, :owner => @owner)
      plan = Factory( :plan, :billable => @course,
                     :user => @course.owner,
                     :members_limit => 5)
      @course.create_quota

      @invited_user = Factory(:user)
      activate_authlogic
      UserSession.create @invited_user

      @course.invite @invited_user
      @params = { :locale => 'pt-BR', :environment_id => @environment.id,
        :id => @course.id }
    end

    context "and accepting" do
      before do
        post :accept, @params
      end

      it "assigns course" do
        assigns[:course].should_not be_nil
      end

      it "accepts the invitation" do
        @invited_user.get_association_with(@course).current_state.
          should == :approved
        @course.approved_users.should include(@invited_user)
      end
    end

    context "and denying" do
      before do
      end

      it "assigns course" do
        post :deny, @params
        assigns[:course].should_not be_nil
      end

      it "denies the invitation" do
        post :deny, @params
        @course.approved_users.should_not include(@invited_user)
      end

      it "detroys the UCA" do
        expect {
          post :deny, @params
        }.should change(UserCourseAssociation, :count).by(-1)
      end
    end
  end

  context "when inviting users (POST invite_members)" do
    before do
      @users = 3.times.inject([]) do |acc,e|
        acc << Factory(:user)
      end
      @emails = ["email@example.com", "email2@example.com",
                 "email3@example.com"]

      @environment = Factory(:environment)
      @course = Factory(:course, :environment => @environment,
                        :owner => @environment.owner)

      activate_authlogic
      UserSession.create @course.owner

      @params = { :locale => 'pt-BR', :environment_id => @course.environment.id,
        :id => @course.id, :users => @users.collect { |u| u.id }.join(","),
        :emails => @emails.collect { |e| e }.join(",") }

    end

    it "creates invitations" do
      post :invite_members, @params

      @users.each do |u|
        @course.user_course_associations.reload
        u.reload
        u.has_course_invitation?(@course).should be_true
      end

      @emails.each do |e|
        u = User.find_by_email(e)
        u.should be_nil
        @course.invited?(e).should be_true
      end
    end
  end

  context "when the limit of members is full" do
    before do
      @user = Factory(:user)
      activate_authlogic
      UserSession.create @user

      @environment = Factory(:environment, :owner => @user)

      @course = Factory(:course,:environment => @environment,
                        :owner => @user)

      plan = Factory( :plan, :billable => @course,
                     :user => @course.owner,
                     :members_limit => 5)
      @course.create_quota

      @users = 4.times.inject([]) { |res, i| res << Factory(:user) }
      @course.join(@users[0])
      @course.join(@users[1])
      @course.join(@users[2])
      @course.join(@users[3])
    end

    context "and course isn't moderated" do
      before do
        @params = { :locale => 'pt-BR',
                    :environment_id => @environment.id,
                    :id => @course.id }
      end

      it "should not authorize more 1 user" do
        @new_user = Factory(:user)
        UserSession.create @new_user
        expect {
          post :join, @params
        }.should_not change(UserCourseAssociation, :count).by(1)
      end

    end

    context "and course is moderated" do
      before do
        @course.subscription_type = 2
        @course.save

        @new_user = Factory(:user)
        @params = { :locale => 'pt-BR',
          :environment_id => @environment.id,
          :id => @course.id }
      end

      context "POST accept" do
        it "should not authorize more 1 user" do
          UserSession.create @user
          @course.invite(@new_user)

          UserSession.create @new_user
          expect {
            post :accept, @params
          }.should_not change(@course.approved_users, :count).by(1)
        end
      end

      context "POST moderate_members" do
        it "should not authorize more 1 user" do
          UserSession.create @user
          @course.join(@new_user)
          @params = { :member => { @new_user.id.to_s => "approve"},
            :id => @course.id, :environment_id => @environment.id,
            :locale => "pt-BR"}
          expect {
            post :moderate_members_requests, @params
          }.should_not change(@course.approved_users, :count).by(1)
        end
      end
    end
  end

  context "when viewing sent invitations (GET admin_manage_invitations)" do
    before do
      environment = Factory(:environment)
      course = Factory(:course, :environment => environment,
                       :owner => environment.owner)
      User.maintain_sessions = false
      activate_authlogic
      UserSession.create course.owner
      user_invitations = (1..3).collect { course.invite Factory(:user) }
      email_invitations = (1..3).collect do |i|
        course.invite_by_email "email#{i}@example.com"
      end

      @params = { :locale => 'pt-BR', :environment_id => course.environment.id,
        :id => course.id }
      get :admin_manage_invitations, @params
    end

    it "assigns user_invitations" do
      assigns[:user_invitations].should_not be_nil
    end

    it "assigns email_invitations" do
      assigns[:email_invitations].should_not be_nil
    end
  end

  context "when removing invitations (POST destroy_invitations)" do
    before do
      @environment = Factory(:environment)
      @course = Factory(:course, :environment => @environment,
                       :owner => @environment.owner)
      User.maintain_sessions = false
      activate_authlogic
      UserSession.create @course.owner
      @user_invitations = (1..4).collect { @course.invite Factory(:user) }
      @email_invitations = (1..4).collect do |i|
        @course.invite_by_email "email#{i}@example.com"
      end

        @params = { :locale => 'pt-BR', :environment_id => @environment.id,
          :id => @course.id }
      end

    context "when email_invitations is empty" do
      before do
        @params[:email_invitations] = ""
        post :destroy_invitations, @params
      end

      it "does NOT destroy email invitations" do
        @course.user_course_invitations.invited.should == @email_invitations
      end
    end


    context "when email_invitations is NOT empty" do
      before do
        @params[:email_invitations] = [@email_invitations[0].id,
                                       @email_invitations[1].id]
        post :destroy_invitations, @params
      end

      it "destroys specified email invitations" do
        @course.user_course_invitations.invited.should == @email_invitations[2..3]
      end
    end


    context "when user_invitations is empty" do
      before do
        @params[:user_invitations] = ""
        post :destroy_invitations, @params
      end

      it "does NOT destroy user invitations" do
        @course.user_course_associations.invited.should == @user_invitations
      end
    end


    context "when user_invitations is NOT empty" do
      before do
        @params[:user_invitations] = [@user_invitations[0].id,
                                       @user_invitations[1].id]
        post :destroy_invitations, @params
      end

      it "destroys specified user invitations" do
        @course.user_course_associations.invited.should == @user_invitations[2..3]
      end
    end
  end
end
