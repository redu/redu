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

  context "GET reports" do
    before do
      environment = Factory(:environment)
      course = Factory(:course, :environment => environment)
      space = Factory(:space, :course => course)
      user = Factory(:user)
      UserEnvironmentAssociation.create(:environment => environment,
                                        :user => user,
                                        :role => Role[:environment_admin])
      UserCourseAssociation.create(:course => course,
                                   :user => user,
                                   :role => Role[:environment_admin])
      activate_authlogic
      UserSession.create user

      get :subject_participation_report, :id => space.id,
        :locale => "pt-BR"
    end

    it "when successful" do
      response.should render_template "spaces/admin/subject_participation_report"
    end

    it "checking user agent" do
      user = (assigns[:user_agent][0])
      user.product.should eq("Rails")
    end
  end
end
