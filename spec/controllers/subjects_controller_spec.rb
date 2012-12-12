require 'spec_helper'
require 'authlogic/test_case'

describe SubjectsController do
  before do
    @user = Factory(:user)
    environment = Factory(:environment, :owner => @user)
    @course = Factory(:course, :environment => environment)
    @space = Factory(:space, :owner => @user, :course => @course)
    @subject_owner = Factory(:user)
    @course.join(@subject_owner)
    login_as @user
  end

  context "GET 'new'" do
    context "when course have a plan" do
      before do
        Factory(:active_package_plan, :billable => @course)
        @course.create_quota
        get :new, :locale => "pt-BR", :space_id => @space.id
      end

      it "assigns a new Subject object" do
        assigns[:subject].should_not be_nil
        assigns[:subject].should be_kind_of(Subject)
        assigns[:subject].should be_new_record
      end

      it "assigns the space" do
        assigns[:space].should_not be_nil
        assigns[:space].should be_kind_of(Space)
      end

      it "assigns the course" do
        assigns[:course].should_not be_nil
        assigns[:course].should be_kind_of(Course)
      end

      it "assigns the environment" do
        assigns[:environment].should_not be_nil
        assigns[:environment].should be_kind_of(Environment)
      end

      it "assigns the quota" do
        assigns[:quota].should_not be_nil
        assigns[:quota].should be_kind_of(Quota)
      end

      it "assigns the plan" do
        assigns[:plan].should_not be_nil
        assigns[:plan].should be_kind_of(Plan)
      end
    end

    context "when course does not have a plan" do
      before do
        @course.plans = []
        @course.quota = nil
        Factory(:active_package_plan, :billable => @course.environment)
        @course.environment.create_quota
        get :new, :locale => "pt-BR", :space_id => @space.id
      end

      it "assigns the quota" do
        assigns[:plan].should_not be_nil
        assigns[:plan].should be_kind_of(Plan)
      end

      it "assigns the plan" do
        assigns[:quota].should_not be_nil
        assigns[:quota].should be_kind_of(Quota)
      end
    end
  end

  context "POST 'create'" do

    context "when successful" do
      before do
        @post_params = {:name => "Subject 1",
          :description => "Lorem ipsum dolor sit amet, consectetur magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
          :space_id => @space.id.to_s}
      end

      it "creates a record with the current user as owner" do
        lambda {
          post :create, :locale => "pt-BR", :subject => @post_params,
          :space_id => @space.id
        }.should change(Subject, :count).by(1)
        Subject.all.last.owner.should == @user
      end

      it "assigns the subject" do
        post :create, :locale => "pt-BR", :subject => @post_params,
          :space_id => @space.id
        assigns[:subject].should_not be_nil
        assigns[:subject].should be_kind_of(Subject)
      end
    end

    context "when failing" do
      before do
        @post_params = {:name => "",
          :description => "Lorem ipsum dolor sit amet, consectetur magna aliqua.",
          :space_id => @space.id.to_s}
      end

      it "does NOT create a record" do
        lambda {
          post :create, :locale => "pt-BR", :format => "js",
          :subject => @post_params, :space_id => @space.id
        }.should_not change(Subject, :count)
      end

      it "assigns the subject" do
        post :create, :locale => "pt-BR", :format => "js",
          :subject => @post_params, :space_id => @space.id
        assigns[:subject].should_not be_nil
        assigns[:subject].should be_kind_of(Subject)
      end
    end
  end

  context "GET 'edit'" do
    before do
      @subject = Factory(:subject, :owner => @subject_owner,
                         :finalized => true, :space => @space)
    end

    it "loads that subject" do
      get :edit, :locale => "pt-BR", :space_id => @space.id, :id => @subject.id
      assigns[:subject].should == @subject
    end
  end

  context "PUT 'update'" do
    before do
      @subject = Factory(:subject, :owner => @subject_owner,
                         :finalized => true, :space => @space)
      lecture = Factory(:lecture, :owner => @user, :subject => @subject)
    end

    context "when successful" do
      it "updates the record" do
        lambda {
          put :update, :locale => "pt-BR", :id => @subject.id,
          :space_id => @space.id,
          :subject => { :name => "Módulo"}
        }.should change{ @subject.reload.name }.to("Módulo")
      end

      it "assigns the subject" do
        put :update, :locale => "pt-BR", :id => @subject.id,
          :space_id => @space.id,
          :subject => { :name => "Módulo"}
        assigns[:subject].should == @subject
      end

    end

    context "when failing" do
      it "does NOT update the record" do
        lambda {
          put :update, :locale => "pt-BR", :id => @subject.id,
          :space_id => @space.id,
          :subject => { :name => "" }
        }.should_not change{ @subject.reload.description }
      end

      it "assigns the subject" do
        put :update, :locale => "pt-BR", :id => @subject.id,
          :space_id => @space.id,
          :subject => { :description => "short description" }
        assigns[:subject].should == @subject
      end
    end
  end

  context "DELETE 'destroy'" do
    before do
      @subject = Factory(:subject, :owner => @subject_owner,
                         :finalized => true ,:space => @space)
      lecture = Factory(:lecture, :owner => @user, :subject => @subject)
    end

    it "destroys the subject" do
      delete :destroy, :locale => "pt-BR", :id => @subject.id,
             :space_id => @space.id
      Subject.all.should_not include(@subject)
    end

    it "redirects to index" do
      delete :destroy, :locale => "pt-BR", :id => @subject.id,
             :space_id => @space.id
      response.should redirect_to(space_path(@subject.space))
    end
  end

  context "GET show" do
    before do
      @subjects  = (1..40).collect do
        Factory(:subject, :owner => @subject_owner, :finalized => true,
                :space => @space)
      end
      @subject = @subjects[15]

      get :show, :locale => "pt-BR", :id => @subject,
        :space_id => @subject.space
    end

    it "assigns subject" do
      assigns[:subject].should == @subject
    end

    it "assigns subject" do
      assigns[:subjects].should_not be_nil
    end
  end
end
