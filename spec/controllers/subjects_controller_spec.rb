require 'spec_helper'
require 'authlogic/test_case'

describe SubjectsController do
  before do
    User.maintain_sessions = false
    @user = Factory(:user)
    environment = Factory(:environment, :owner => @user)
    @course = Factory(:course, :environment => environment)
    @space = Factory(:space, :owner => @user, :course => @course)
    @subject_owner = Factory(:user)
    @course.join(@subject_owner)
    activate_authlogic
    UserSession.create @user
  end

  context "GET 'index'" do
    before do
      subjects = (1..3).collect { Factory(:subject, :owner => @subject_owner,
                                          :space => @space,
                                          :published => true,
                                          :finalized => true) }
    end

    it "loads all space subjects" do
      get :index, :locale => "pt-BR", :space_id => @space.id
      assigns[:subjects].to_set.should == @space.subjects.to_set
    end

    it "renders with layout 'environment'" do
      get :index, :locale => "pt-BR", :space_id => @space.id
      response.layout.should == 'layouts/new/application'
    end

  end


  context "GET 'show'" do
    before do
      @subject = Factory(:subject, :owner => @subject_owner,
                         :published => true, :space => @space,
                         :finalized => true)
    end
    it "loads that subject" do
      get :show, :locale => "pt-BR", :space_id => @space.id,
                                     :id => @subject.id
      assigns[:subject].should == @subject
    end
  end

  context "GET 'new'" do
    before do
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

  end

  context "POST 'create'" do

    context "when successful" do
      before do
        @post_params = {:title => "Subject 1",
          :description => "Lorem ipsum dolor sit amet, consectetur magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
          :tag_list => "list, of, tags", :space_id => @space.id.to_s}
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
        @post_params = {:title => "",
          :description => "Lorem ipsum dolor sit amet, consectetur magna aliqua.",
          :tag_list => "list, of, tags", :space_id => @space.id.to_s}
      end

      it "does NOT create a record" do
        lambda {
          post :create, :locale => "pt-BR", :subject => @post_params,
          :space_id => @space.id
        }.should_not change(Subject, :count)
      end

      it "assigns the subject" do
        post :create, :locale => "pt-BR", :subject => @post_params,
          :space_id => @space.id
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
      lecture = Factory(:lecture, :owner => @user)
      @subject = Factory(:subject, :owner => @subject_owner,
                         :finalized => true, :space => @space,
                         :lectures => [lecture])
    end

    context "when successful" do
      it "updates the record" do
        lambda {
          put :update, :locale => "pt-BR", :id => @subject.id,
          :space_id => @space.id,
          :subject => { :title => "Módulo"}
        }.should change{ @subject.reload.title }.to("Módulo")
      end

      it "assigns the subject" do
        put :update, :locale => "pt-BR", :id => @subject.id,
          :space_id => @space.id,
          :subject => { :title => "Módulo"}
        assigns[:subject].should == @subject
      end

    end

    context "when failing" do
      it "does NOT update the record" do
        lambda {
          put :update, :locale => "pt-BR", :id => @subject.id,
          :space_id => @space.id,
          :subject => { :description => "short description" }
        }.should_not change{ @subject.reload.description }
      end

      it "assigns the subject" do
        put :update, :locale => "pt-BR", :id => @subject.id,
          :space_id => @space.id,
          :subject => { :description => "short description" }
        assigns[:subject].should == @subject
      end

      it "re-renders 'edit'" do
        put :update, :locale => "pt-BR", :id => @subject.id,
          :space_id => @space.id,
          :subject => { :description => "short description" }
        response.should render_template('subjects/new/update_error')
      end
    end
  end

  context "DELETE 'destroy'" do
    before do
      lecture = Factory(:lecture, :owner => @user)
      @subject = Factory(:subject, :owner => @subject_owner,
                         :finalized => true ,:space => @space,
                         :lectures => [lecture])
    end

    it "destroys the subject" do
      delete :destroy, :locale => "pt-BR", :id => @subject.id,
             :space_id => @space.id
      Subject.all.should_not include(@subject)
    end

    it "redirects to index" do
      delete :destroy, :locale => "pt-BR", :id => @subject.id,
             :space_id => @space.id
      response.should redirect_to(space_subjects_path(@subject.space))
    end
  end

  context "GET 'admin_lectures_order'" do
    before do
      @subject = Factory(:subject, :owner => @subject_owner,
                         :space => @space, :finalized => true)
    end
    it "assigns the subject" do
      get :admin_lectures_order, :locale => "pt-BR", :id => @subject.id,
             :space_id => @space.id
      assigns[:subject].should == @subject
    end
  end

  context "POST 'admin_lectures_order'" do
    before do
      lecture = Factory(:lecture, :owner => @user)
      @subject = Factory(:subject, :owner => @subject_owner,
                         :space => @space, :lectures => [lecture],
                         :finalized => true)
      post :admin_lectures_order, :locale => "pt-BR", :id => @subject.id,
        :space_id => @space.id,
        :lectures_ordered => "#{lecture.id}-lecture"
    end

    it "assigns the subject" do
      assigns[:subject].should == @subject
    end

    it "redirects to GET admin_lectures_order" do
      response.should redirect_to(admin_lectures_order_space_subject_path(@space, @subject))
    end
  end

  context "GET 'publish'" do
    before do
      lecture = Factory(:lecture, :owner => @user)
      @subject = Factory(:subject, :owner => @subject_owner,
                         :finalized => true ,:space => @space, :lectures => [lecture])
      get :publish, :locale => "pt-BR", :id => @subject.id,
        :space_id => @space.id
    end

    it "assigns the subject" do
      assigns[:subject].should == @subject
    end

    it "redirects to 'show'" do
      response.should redirect_to(space_subject_path(@space, @subject))
    end
  end

  context "GET 'unpublish'" do
    before do
      lecture = Factory(:lecture, :owner => @user)
      @subject = Factory(:subject, :owner => @subject_owner,
                         :space => @space, :finalized => true,
                         :lectures => [lecture])
      get :unpublish, :locale => "pt-BR", :id => @subject.id, :space_id => @space.id
    end

    it "assigns the subject" do
      assigns[:subject].should == @subject
    end

    it "redirects to 'show'" do
      response.should redirect_to(space_subject_path(@space, @subject))
    end
  end

  context "GET 'enroll'" do
    before do
      lecture = Factory(:lecture, :owner => @user)
      @subject = Factory(:subject, :owner => @subject_owner,
                         :space => @space, :finalized => true,
                         :lectures => [lecture], :published => true)
      @enrolled_user = Factory(:user)
      Factory(:user_space_association, :space => @space,
              :user => @enrolled_user)
      get :enroll, :locale => "pt-BR", :id => @subject.id,
        :space_id => @space.id
    end

    it "assigns the subject" do
      assigns[:subject].should == @subject
    end

    it "redirects to 'show'" do
      response.should redirect_to(space_subject_path(@space, @subject))
    end
  end

  context "GET 'unenroll'" do
    before do
      lecture = Factory(:lecture, :owner => @user)
      @subject = Factory(:subject, :owner => @subject_owner,
                         :space => @space, :finalized => true,
                         :lectures => [lecture],
                         :published => 1)
      @enrolled_user = Factory(:user)
      @course.join(@enrolled_user)
      @subject.enroll(@enrolled_user)
      UserSession.create @enrolled_user
      get :unenroll, :locale => "pt-BR", :id => @subject.id,
        :space_id => @space.id
    end

    it "assigns the subject" do
      assigns[:subject].should == @subject
    end

    it "redirects to 'show'" do
      response.should redirect_to(space_subject_path(@space, @subject))
    end
  end
end
