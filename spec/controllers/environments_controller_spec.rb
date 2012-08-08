require 'spec_helper'
require 'authlogic/test_case'
include Authlogic::TestCase

describe EnvironmentsController do
  context "when creating a paid Environment" do
    before do
      User.maintain_sessions = false
      @user = Factory(:user)
      activate_authlogic
      UserSession.create @user

      @params = {:step => "1",
        :environment => {:name => "Faculdade mauricio de nassau",
          :initials => "FMN",
          :courses_attributes => [{:name => "Gestão de TI",
                                   :path => "gestao-de-ti"}],
        :path => "faculdade-mauricio-de-nassau"},
        :locale => "pt-BR"}

      # Para a importação de conteúdo básico para Ensino Médio
      @base_course = Factory(:complete_course, 
                             :name => 'Conteúdo Básico para E.M.')
    end

    context "at step 1" do

      it "assigns the environment" do
        post :create, @params
        assigns[:environment].should_not be_nil
        assigns[:environment].should be_valid
        assigns[:step].should == 2
      end

      # Para os outros passos, o bloco abaixo é usado a partir de 
      # basic_content_proxy_shared_examples.rb
      context "with a course which imports basic content" do
        before do
          hash = { :basic_content => true, :base_course_id => @base_course.id }
          @params = @params.merge hash
        end

        it "assigns basic content variables" do
          post :create, @params
          assigns[:has_basic_content].should be_true
          assigns[:base_course_id].should_not be_nil
        end
      end
    end # context "at step 1"

    context "at step 2" do
      before do
        @params[:step] = "2"
        @params[:plan] = "professor_standard"
      end

      it "assigns the environment" do
        post :create, @params
        assigns[:environment].should_not be_nil
        assigns[:environment].should be_valid
        assigns[:step].should == 3
      end

      it "assigns the plan" do
        post :create, @params
        assigns[:plan].should == @params[:plan]
      end

      it_should_behave_like "a basic content variables proxy" do
        let(:params) { @params }
        let(:base_course) { @base_course }
      end
    end

    context "at step 3" do
      context "when is valid" do
        before do
          @params[:step] = "3"
          @params[:plan] = "professor_standard"
        end

        it "assigns the environment" do
          post :create, @params
          assigns[:environment].should_not be_nil
          assigns[:environment].should be_valid
          assigns[:step].should == 4
        end

        it "assigns the plan" do
          post :create, @params
          assigns[:plan].should == @params[:plan]
        end

        it_should_behave_like "a basic content variables proxy" do
          let(:params) { @params }
          let(:base_course) { @base_course }
        end
      end

      context "when isn't valid" do
        before do
          @params[:step] = "3"
          @params[:plan] = "professor_standard"
          @params[:environment][:name] = ""
          post :create, @params
        end

        it "assigns the environment" do
         assigns[:environment].should_not be_nil
         assigns[:environment].should_not be_valid
         assigns[:step].should == 3
        end

        it "assigns the plan" do
          assigns[:plan].should_not be_nil
        end

        it_should_behave_like "a basic content variables proxy" do
          let(:params) { @params }
          let(:base_course) { @base_course }
        end
      end
    end

    context "at step 4" do
      context "when plain request" do
        before do
          @params[:step] = "4"
          @params[:plan] = "professor_standard"
          @params[:color] = "f56b00"

          post :create, @params
        end

        it "assigns and creates the environment" do
          assigns[:environment].should_not be_nil
          assigns[:environment].should_not be_new_record
        end

        it "assigns and creates the plan" do
          assigns[:plan].should_not be_nil
          assigns[:plan].should be_valid
          assigns[:plan].should_not be_new_record
        end

        it "associates the plan to the course" do
          assigns[:environment].courses.first.plan.should == assigns[:plan]
        end

        it "associates the quota to the course" do
          course = assigns[:environment].courses.first
          course.quota.should_not be_nil
        end

        it "associates the plan with the user" do
          assigns[:plan].user.should == @user
        end

        it "creates the first order" do
          assigns[:plan].invoices.size.should == 1
        end

        it "redirects to confirmation page" do
          should redirect_to(confirm_plan_path(assigns[:plan]))
        end

        it_should_behave_like "a basic content variables proxy" do
          let(:params) { @params }
          let(:base_course) { @base_course }
        end
      end

      context "when observers are enabled" do
        before do
          @params[:step] = "4"
          @params[:plan] = "professor_standard"
          @params[:color] = "f56b00"
        end

        it "associates the plan to the course" do
          ActiveRecord::Observer.with_observers :course_observer do
            expect {
              post :create, @params
            }.should_not raise_error
          end
        end
      end

      context "when AJAX request" do
        before do
          @params[:step] = "4"
          @params[:plan] = "professor_standard"
          @params[:color] = "f56b00"
          @params[:body] = "js"
          post :create, @params
        end

        it "assigns and creates the environment" do
          assigns[:environment].should_not be_nil
          assigns[:environment].should_not be_new_record
        end

        it "assigns and creates the plan" do
          assigns[:plan].should_not be_nil
          assigns[:plan].should be_valid
          assigns[:plan].should_not be_new_record
        end

        it "associates the plan to the course" do
          assigns[:environment].courses.first.plan.should == assigns[:plan]
        end

        it "associates the quota to the course" do
          course = assigns[:environment].courses.first
          course.quota.should_not be_nil
        end

        it "associates the plan with the user" do
          assigns[:plan].user.should == @user
        end

        it "creates the first order" do
          assigns[:plan].invoices.size.should == 1
        end

      end
    end

    context "at step 4 for free" do
      before do
        @params[:step] = "4"
        @params[:plan] = "free"
        @params[:color] = "f56b00"
        @params[:locale] = "pt-BR"
        @params[:format] = "js"
      end

      it "redirects to course page" do
        post :create, @params
        response.should render_template "environments/redirect"
      end

      context "with a course which imports basic content" do
        before do
          hash = { :basic_content => "true", :base_course_id => @base_course.id }
          @params = @params.merge hash
        end

        it "creates a course with a nonzero number of initial spaces" do
          post :create, @params
          assigns[:environment].courses.first.spaces.each.count.should_not == 0
        end
      end
    end
  end

  context "GET preview" do
    before do
      environment = Factory(:environment)
      courses = (1..5).collect { Factory(:course, :environment => environment) }

      get :preview, :id => environment.path, :locale => "pt-BR"
    end

    it "assigns courses" do
      assigns[:courses].should_not be_nil
    end
  end

  # admin actions (management panel)
  context "on management panel" do
    before  do
      @environment = Factory(:environment)
      @courses = (1..3).collect { Factory(:course, :environment => @environment) }
      @user = Factory(:user)
      @courses.each {|c| c.join @user, :environment_admin }
      activate_authlogic
      UserSession.create @user
    end

    context "GET edit" do
      before do
        get :edit, :locale => "pt-BR", :id => @environment.path
      end

      it "assigns environment" do
        assigns[:environment].should_not be_nil
      end

      it "assigns header_environment" do
        assigns[:header_environment].should_not be_nil
      end

      it "renders admin/edit" do
        response.should render_template "environments/admin/edit"
      end
    end

    context "POST update" do
      context "when successful" do
        before do
          @post_params = { :environment => { :name => "Pe" , :initials => "PE",
            :path => @environment.path, :tag_list => "", :description => "" } }
          @post_params[:locale] = "pt-BR"
          @post_params[:id] = @environment.path
          post :update, @post_params
        end

        it "redirects to Environments#show" do
          response.should redirect_to(environment_path(@environment))
        end
      end

      context "when failing" do
        before do
          @post_params = { :environment => { :name => "" , :initials => "PE",
            :path => "", :tag_list => "", :description => "" } }
          @post_params[:locale] = "pt-BR"
          @post_params[:id] = @environment.path
          post :update, @post_params
        end

        it "re-renders environments/admin/edit" do
          response.should render_template "environments/admin/edit"
        end
      end
    end

    context "POST destroy" do
      before do
        @plan = Factory(:active_package_plan, :billable => @environment)
        @post_params = { :locale => "pt-BR" }
        @post_params[:id] = @environment.path
        post :destroy, @post_params
      end

      it "should store billable" do
        @plan.reload.billable_audit.should_not be_nil
      end
    end

    context "POST destroy_members" do
      before do
        @courses.each do |c|
          (1..2).each { Factory(:space, :course => c) }
          c.spaces.reload
        end

        @users = (1..3).collect { Factory(:user) }
        @courses[0].join @users[0]
        @courses[0].join @users[1]
        @courses[0].join @users[2]

        @courses[1].join @users[1]
        @courses[2].join @users[2]
      end

      it "calls remove_users" do
        Environment.any_instance.should_receive(:remove_users).
          with(@users[0..1])
        post_destroy_members(@environment, @users[0..1])
      end

      it 'sets flash properly' do
        post_destroy_members(@environment, @users[0..1])

        should set_the_flash.to("Os usuários foram removidos do ambiente #{@environment.name}")
      end
    end
  end

  def post_destroy_members(environment, users)
    post :destroy_members, :locale => 'pt-BR',
      :id => environment.to_param,
      :users => users.collect { |u| u.id }
  end
end
