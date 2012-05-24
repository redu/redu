require 'spec_helper'
require 'authlogic/test_case'
include Authlogic::TestCase

describe SpacesController do
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
    before do
      environment = Factory(:environment)
      course = Factory(:course, :environment => environment)
      @space = Factory(:space, :course => course)
      user = Factory(:user)
      @space.course.join user, Role[:environment_admin]

      activate_authlogic
      UserSession.create user

      application = ClientApplication.where(:name => "ReduViz").first
      AccessToken.create(:client_application => application, :user => user)
    end

    context "subject participation" do
      before do
        get :subject_participation_report, :id => @space.id,
          :locale => "pt-BR"
      end

      it "when successful" do
        response.should render_template "spaces/admin/subject_participation_report"
      end

      it "checking user agent" do
        user = (assigns[:user_agent][0])
        user.product.should eq("Rails")
      end

      it "assign a valid token" do
        token = assigns[:token]
        token.should eq(AccessToken.first.token)
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

      it "assign a valid token" do
        token = assigns[:token]
        token.should eq(AccessToken.first.token)
      end
    end
  end
end
