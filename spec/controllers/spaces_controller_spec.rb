require 'spec_helper'
require 'authlogic/test_case'
require 'vis_application_additions'

describe SpacesController do
  include Authlogic::TestCase

  context "GET students_endless" do
    before do
      environment = Factory(:environment, :published => true)
      course = Factory(:course, :environment => environment)
      space = Factory(:space, :course => course)
      user = Factory(:user)
      space.course.join user

      activate_authlogic
      UserSession.create user

      get :students_endless, :id => space.id, :locale => "pt-BR",
        :format => "js"
    end

    it "should be_success" do
      response.should be_success
    end

    it "assigns @sidebar_students" do
      assigns[:sidebar_students].should_not be_nil
    end
  end

  context "GET report" do
    include VisApplicationAdditions::Utils

    before do
      environment = Factory(:environment)
      course = Factory(:course, :environment => environment)
      @space = Factory(:space, :course => course)
      user = Factory(:user)
      @space.course.join user, Role[:environment_admin]

      activate_authlogic
      UserSession.create user

      application = ClientApplication.create(:name => "ReduVis",
                                             :url => "http://www.redu.com.br",
                                             :walledgarden => true)
      create_token_for(user)
    end

    context "subject participation" do
      before do
        get :subject_participation_report, :id => @space.id,
          :locale => "pt-BR"
      end

      it "when successful" do
        response.should render_template "spaces/admin/subject_participation_report"
      end

      it "browser should be supported" do
        supported = assigns[:browser_not_supported]
        supported.should_not be_true
      end
    end

    context "lecture participation" do
      before do
        get :lecture_participation_report, :id => @space.id,
          :locale => "pt-BR"
      end

      it "when successful" do
        response.should render_template "spaces/admin/lecture_participation_report"
      end

      it "browser should be supported" do
        supported = assigns[:browser_not_supported]
        supported.should_not be_true
      end
    end

    context "students participation" do
      before do
        get :students_participation_report, :id => @space.id,
          :locale => "pt-BR"
      end

      it "when successful" do
        response.should render_template "spaces/admin/students_participation_report"
      end

      it "browser should be supported" do
        supported = assigns[:browser_not_supported]
        supported.should_not be_true
      end

      it "assign a valid token" do
        token = assigns[:token]
        token.should eq(Oauth2Token.first.token)
      end
    end
  end
end
