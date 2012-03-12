require "spec_helper"
require 'authlogic/test_case'
include Authlogic::TestCase

describe Vis::DashboardController do
  context "authorizing" do
    before do
      @environment = Factory(:environment)
      @course = Factory(:course, :environment => @environment,
                        :owner => @environment.owner)
      3.times.collect do
        u = Factory(:user)
        @course.join(u, Role[:teacher])
      end

      @user = @environment.owner
    end

    context "GET teacher_participation" do
      it "should return 401 (unauthorized) HTTP code" do
        get :teacher_participation, :course_id => @course.id,
          :format =>'json', :locale => "pt-BR"

        response.code.should == "401"
      end

      it "should not return any data" do
        get :teacher_participation,
          :course_id => @course.id, :locale => "pt-BR", :format =>'json'

        ActiveSupport::JSON.decode(response.body).
          should have_key 'error'
      end

      it "should return 200 (Ok) HTTP code" do
        activate_authlogic
        UserSession.create @user

        @course.join(@user, Role[:environment_admin])
        get :teacher_participation, :course_id => @course.id,
          :format => "json", :locale => "pt-BR"

        response.code.should == "200"
      end
    end

    context "GET teacher_participation_interaction" do
      before do
        @environment.courses.reload
        @space = Factory(:space, :owner => @environment.owner,
                         :course => @environment.courses.first)
        @course.spaces.reload
        @params = { :course_id => @course.id,
                    :teacher_id => @course.teachers.first.id,
                    :date_start => "2012-03-01",
                    :date_end => "2012-03-10",
                    :spaces => [@space.id.to_s],
                    :format => :json,
                    :locale => "pt-BR" }
      end

      it "should return 401 (unauthorized) HTTP code" do
        get :teacher_participation_interaction, @params

        response.code.should == "401"
      end

      it "should not return any data" do
        get :teacher_participation_interaction, @params

        ActiveSupport::JSON.decode(response.body).
          should have_key 'error'
      end

      it "should return 200 (Ok) HTTP code" do
        activate_authlogic
        UserSession.create @user

        @course.join(@user, Role[:environment_admin])
        get :teacher_participation_interaction, @params

        response.code.should == "200"
      end
    end
  end
end
