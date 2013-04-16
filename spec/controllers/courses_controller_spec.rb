require 'spec_helper'
require 'authlogic/test_case'

describe CoursesController do
  context "when creating a course for an existing environment" do
    before do
      @user = Factory(:user)
      login_as @user

      @environment = Factory(:environment, :owner => @user)

      @params = {:course =>
        { :name => "Redu", :workload => "12",
          :tag_list => "minhas, tags, exemplo, aula, teste",
          :path => "redu", :subscription_type => "1",
          :description => "Lorem ipsum dolor sit amet, consectetur" \
          "magna aliqua. Ut enim ad minim veniam, quis nostrud" \
          "ullamco laboris nisi ut aliquip ex ea commodo."},
          :plan => "free",
          :environment_id => @environment.path,
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

    context "POST create" do
      it "should be a professor_lite plan" do
        @params[:plan] = "professor_lite"
        post :create, @params
        assigns[:plan].name.should == "Professor Lite"
      end

      it "should not generate invoice for free plans" do
        @params[:plan] = "free"

        expect {
          post :create, @params
        }.should_not change(Invoice, :count)
      end
    end
  end

  context "when updating a couse" do
    context "POST update - updating a subscription_type to 1" do
      before do
        @user = Factory(:user)
        login_as @user

        @environment = Factory(:environment, :owner => @user)

        @course = Factory(:course,:environment => @environment, :owner => @user,
                          :subscription_type => 2)
        @users = 5.times.inject([]) { |res, i| res << Factory(:user) }
        @course.join(@users[0])
        @course.join(@users[1])
        @course.join(@users[2])
        @course.join(@users[3])
        @course.join(@users[4])

        @params = {:course => { :subscription_type => "1" },
          :id => @course.path,:environment_id => @course.environment.path,
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
      login_as @user

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

      login_as @user
    end

    context "POST - rejecting members" do
      before do
        @params = { :member => { @users[1].id.to_s => "reject",
          @users[2].id.to_s => "reject",
          @users[3].id.to_s => "approve"},
          :id => @course.path, :environment_id => @environment.path,
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

      it "should not raise error when moderating again" do
        expect {
          post :moderate_members_requests, @params
        }.to_not raise_error(AASM::InvalidTransition)
      end
    end

    context "POST - accepting member" do
      before do
        @params = { :member => { @users[1].id.to_s => "approve",
          @users[2].id.to_s => "approve"},
          :id => @course.path, :environment_id => @environment.path,
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

      it "should not raise error when moderating again" do
        expect {
          post :moderate_members_requests, @params
        }.to_not raise_error(AASM::InvalidTransition)
      end
    end

    context "when course does not have a plan" do
      before do
        @course.plans = []

        @plan = Factory(:active_licensed_plan, :billable => @course.environment,
                       :user => @course.environment.owner)
        @plan.create_invoice


        @params = { :member => { @users[1].id.to_s => "approve",
          @users[2].id.to_s => "approve"},
          :id => @course.path, :environment_id => @environment.path,
          :locale => "pt-BR"}
      end

      it "should approve association" do
        post :moderate_members_requests, @params
        @course.approved_users.to_set.should == [@users[1], @users[2], @user].to_set
      end

      it "should create only two licenses" do
        expect{
          post :moderate_members_requests, @params
        }.should change(License, :count).from(0).to(2)
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
      @subjects.each { |sub| sub.enroll @user }
      login_as @user

      @params = { :locale => 'pt-BR', :environment_id => @environment.path,
        :id => @course.path }
    end

    context "and it's the unique course which user has joined" do
      before do
        @course.join @user
        post :unjoin, @params
      end

      it "assigns course"

      it "removes the user from itself" do
        @course.users.should_not include(@user)
      end

      it "removes the user from all spaces" do
        @spaces.collect { |s| s.users.should_not include(@user) }
      end

      it "removes the user from all enrolled subjects" do
        @subjects.collect { |s| s.members.should_not include(@user) }
      end

      it "should remove user from environment" do
        @environment.users.should_not include(@user)
      end
    end # context "and it's the unique course which user has joined"

    context "and it's not the unique course which user has joined" do
      before do
        @course2 = Factory(:course, :environment => @environment, :owner => @owner)
        @course2.join @user
        @course.join @user
        post :unjoin, @params
      end

      it "should remove the user from itself" do
        @course.users.should_not include(@user)
      end
      it "should remove the user from all spaces" do
        @spaces.collect { |s| s.users.should_not include(@user) }
      end
      it "should remove the user from all enrolled subjects" do
        @subjects.collect { |s| s.members.should_not include(@user) }
      end
      it "should not remove user from others courses" do
        @course2.users.should include(@user)
      end
      it "should not remove user from environment" do
        @environment.users.should include(@user)
      end
    end # context "and it's not the unique course which user has joined"
  end # context "when unjoin from a course (POST unjoin)"

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
      login_as @invited_user

      @course.invite @invited_user
      @params = { :locale => 'pt-BR', :environment_id => @environment.path,
        :id => @course.path }
    end

    context "and accepting" do
      before do
        post :accept, @params
      end

      it "assigns course" do
        assigns[:course].should_not be_nil
      end

      it "accepts the invitation" do
        @invited_user.get_association_with(@course).state.
          should == "approved"
        @course.approved_users.should include(@invited_user)
      end
    end

    context "and denying" do
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

  context "when destroying members" do
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

      @users = 3.times.inject([]) { |acc,i| acc << Factory(:user) }
      @users.each { |u| @course.join u }

      login_as @owner

      @params = { :locale => 'pt-BR', :environment_id => @environment.path,
                  :id => @course.path, "users" => @users.collect { |u| u.id } }
      post :destroy_members, @params
    end

    it "destroys UCA" do
      @users.each do |u|
        u.get_association_with(@course).should be_nil
      end
    end

    it "destroys USA" do
      usas = @spaces.collect do |s|
        @users.collect { |u| u.get_association_with(s) }
      end.flatten

      usas.inject(true) { |acc,i| acc && (i.nil?) }.should be_true
    end

    it "destroys enrollments" do
      enrollments = @spaces.collect do |s|
        s.subjects.collect do |subj|
          @users.collect { |u| u.get_association_with(subj) }
        end
      end.flatten

      enrollments.inject(true) { |acc,i| acc && (i.nil?) }.should be_true
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

      login_as @course.owner

      @params = { :locale => 'pt-BR', :environment_id => @course.environment.path,
        :id => @course.path, :users => @users.collect { |u| u.id }.join(","),
        :emails => @emails.collect { |e| e }.join(",") }

    end

    it "creates invitations" do
      post :invite_members, @params

      @users.each do |u|
        @course.user_course_associations.reload
        u.reload
        @course.waiting_user_approval?(u).should be_true
      end

      @emails.each do |e|
        u = User.find_by_email(e)
        u.should be_nil
        @course.invited?(e).should be_true
      end
    end
  end

  context "POST join" do

    context "when course is open" do
      before do
        @user = Factory(:user)
        login_as @user

        @environment = Factory(:environment, :owner => @user)

        @course = Factory(:course,:environment => @environment,
                          :owner => @user)

        @plan = Factory(:active_licensed_plan, :billable => @environment,
                       :user => @course.owner)
        @plan.create_invoice_and_setup

        @environment.create_quota
        @environment.reload

        @space = Factory(:space, :course => @course)
        @subject_space = Factory(:subject, :space => @space,
                                 :owner => @course.owner,
                                 :finalized => true)

        @params = { :locale => 'pt-BR',
                    :environment_id => @environment.path,
                    :id => @course.path }

        @new_user = Factory(:user)
        login_as @new_user
      end

      it "should create all hieararchy" do
        post :join, @params

        @course.users.should include(@new_user)
        @space.users.should include(@new_user)
        @subject_space.members.should include(@new_user)
        @course.environment.users.should include(@new_user)
      end

      context "and plan is licensed" do
        it "should create license on respective invoice" do
          expect {
            post :join, @params
          }.should change(License, :count).by(1)
        end
      end

    end
  end

  context "when the limit of members is full" do
    before do
      @user = Factory(:user)
      login_as @user

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
          :environment_id => @environment.path,
          :id => @course.path }
      end

      it "should not authorize more 1 user" do
        @new_user = Factory(:user)
        login_as  @new_user
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
          :environment_id => @environment.path,
          :id => @course.path }
      end

      context "POST accept" do
        it "should not authorize more 1 user" do
          login_as @user
          @course.invite(@new_user)

          login_as @new_user
          expect {
            post :accept, @params
          }.should_not change(@course.approved_users, :count).by(1)
        end
      end

      context "POST moderate_members" do
        it "should not authorize more 1 user" do
          login_as @user
          @course.join(@new_user)
          @params = { :member => { @new_user.id.to_s => "approve"},
            :id => @course.path, :environment_id => @environment.path,
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
      login_as course.owner
      user_invitations = (1..3).collect { course.invite Factory(:user) }
      email_invitations = (1..3).collect do |i|
        course.invite_by_email "email#{i}@example.com"
      end

      @params = { :locale => 'pt-BR', :environment_id => course.environment.path,
        :id => course.path }
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
      login_as @course.owner
      @user_invitations = (1..4).collect { @course.invite Factory(:user) }
      @email_invitations = (1..4).collect do |i|
        @course.invite_by_email "email#{i}@example.com"
      end

      @params = { :locale => 'pt-BR', :environment_id => @environment.path,
        :id => @course.path }
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

  # admin actions (management panel)
  context "on management panel" do
    before  do
      @environment = Factory(:environment)
      @course = Factory(:course, :environment => @environment)
      @user = Factory(:user)
      UserEnvironmentAssociation.create(:environment => @environment,
                                        :user => @user,
                                        :role => Role[:environment_admin])
      UserCourseAssociation.create(:course => @course,
                                   :user => @user,
                                   :role => Role[:environment_admin])
      login_as @user
    end

    context "GET new" do
      before do
        get :new, :locale => "pt-BR", :environment_id => @environment.path
      end

      it "assigns environment" do
        assigns[:environment].should_not be_nil
      end

      it "assigns course" do
        assigns[:course].should_not be_nil
      end

      it "renders admin/new" do
        response.should render_template "courses/admin/new"
      end
    end

    context "POST create" do
      context "when environment has plan" do
        before do
          @post_params = {:course => { :name => "course", :workload => "",
                                        :path => "course-path", :tag_list => "",
                                        :description => "",
                                        :subscription_type => "1" } }
          @post_params[:locale] = "pt-BR"
          @post_params[:environment_id] = @environment.path
          Factory(:active_licensed_plan, :billable => @environment)
          @environment.reload
          post :create, @post_params
        end

        it "should not create the plan" do
          assigns[:course].plan.should be_nil
        end

        it "should not create the quota and computes it" do
          assigns[:course].quota.should be_nil
        end

      end

      context "when successful" do
        before do
          @post_params = { :plan => "free",
                           :course => { :name => "course", :workload => "",
                                        :path => "course-path", :tag_list => "",
                                        :description => "",
                                        :subscription_type => "1" } }
          @post_params[:locale] = "pt-BR"
          @post_params[:environment_id] = @environment.path
        end

        it "redirects to Courses#show" do
          post :create, @post_params
          response.should redirect_to(environment_course_path(@environment, Course.last))
        end
      end

      context "when failing" do
        before do
          @post_params = { :plan => "free",
                           :course => { :name => "", :workload => "",
                                        :path => "", :tag_list => "",
                                        :description => "",
                                        :subscription_type => "1" } }
          @post_params[:locale] = "pt-BR"
          @post_params[:environment_id] = @environment.path
          post :create, @post_params
        end

        it "re-renders course/admin/new" do
          response.should render_template "courses/admin/new"
        end
      end
    end

    context "GET edit" do
      before do
        get :edit, :locale => "pt-BR", :environment_id => @environment.path,
          :id => @course.path
      end

      it "assigns environment" do
        assigns[:environment].should_not be_nil
      end

      it "assigns course" do
        assigns[:course].should_not be_nil
      end

      it "renders admin/edit" do
        response.should render_template "courses/admin/edit"
      end
    end

    context "POST update" do
      context "when successful" do
        before do
          @post_params = { :plan => "free",
                           :course => { :name => "course", :workload => "",
                                        :path => "course-path-changed",
                                        :tag_list => "", :description => "",
                                        :subscription_type => "1" } }
          @post_params[:locale] = "pt-BR"
          @post_params[:environment_id] = @environment.path
          @post_params[:id] = @course.path
          post :update, @post_params
        end

        it "redirects to Environments#show" do
          response.should redirect_to(environment_course_path(@environment,
                                                              @course.reload))
        end
      end

      context "when failing" do
        before do
          @post_params = { :plan => "free",
                           :course => { :name => "course", :workload => "",
                                        :path => "",
                                        :tag_list => "", :description => "",
                                        :subscription_type => "1" } }
          @post_params[:locale] = "pt-BR"
          @post_params[:environment_id] = @environment.path
          @post_params[:id] = @course.path
          post :update, @post_params
        end

        it "re-renders courses/admin/edit" do
          response.should render_template "courses/admin/edit"
        end
      end
    end

    context "GET reports" do
      before do
        get :teacher_participation_report, :locale => "pt-BR",
          :environment_id => @environment.path, :id => @course.path
      end

      it "when successful" do
        response.should render_template "courses/admin/teacher_participation_report"
      end
    end
  end

  context "when course is unpublished" do
    before do
      @course = Factory(:course, :published => false)
    end

    context "GET show" do
      before do
        get :show, @params = { :locale => 'pt-BR', :environment_id => @course.environment.path,
        :id => @course.path }
      end

      it "should show the preview page" do
        response.should redirect_to(preview_environment_course_path(@course.environment,
                                                                    @course))
      end
    end
  end

  context "GET preview" do
    before do
      @course = Factory(:course)
    end

    context "when have permission to see the course" do
      before do
        @user = Factory(:user)
        @course.join @user
        login_as @user

        get :preview, :locale => "pt-BR",
          :environment_id => @course.environment.to_param,
          :id => @course.to_param
      end

      it "redirects to #show" do
        response.should redirect_to(environment_course_path(@course.environment,
                                                            @course))
      end
    end


    context "when is course's admin" do
      before do
        @env_admin = Factory(:user)
        @course.join @env_admin, Role[:environment_admin]
        login_as @env_admin

        get :preview, :locale => "pt-BR",
          :environment_id => @course.environment.to_param,
          :id => @course.to_param
      end

      it "redirects to #show" do
        response.should redirect_to(environment_course_path(@course.environment,
                                                            @course))
      end
    end

    context "when does NOT have permission to see the course" do
      before do
        get :preview, :locale => "pt-BR",
          :environment_id => @course.environment.to_param,
          :id => @course.to_param
      end

      it "renders preview" do
        response.should  render_template("courses/preview")
      end
    end
  end

  context "when visiting a course" do
    let(:course) { Factory(:course) }
    let(:user) { Factory(:user) }

    context "as a course's member" do
      before do
        login_as user
        course.join! user
      end

      it "updates uca's last_accessed_at" do
        expect {
          get :show, @params = { :locale => 'pt-BR',
                                 :environment_id => course.environment.to_param,
                                 :id => course.to_param }
        }.should change { user.user_course_associations.last.last_accessed_at }
      end
    end
  end

  context "GET search_users_admin" do
    let(:course) { Factory(:course) }
    let(:environment) { course.environment }
    let(:user) { course.owner }

    before do
      login_as user

      xhr :get, :search_users_admin, :locale => "pt-BR",
        :environment_id => environment.to_param, :id => course.to_param
    end

    it "assigns memberships" do
      assigns[:memberships].should_not be_nil
    end

    it "assigns spaces_count" do
      assigns[:spaces_count].should_not be_nil
    end

    it "renders admin/search_users_admin" do
      response.should render_template "courses/admin/search_users_admin"
    end
  end
end
