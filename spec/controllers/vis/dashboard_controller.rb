require "spec_helper"
require 'authlogic/test_case'

describe Vis::DashboardController do
  include Authlogic::TestCase

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

  context "authorizing GET teacher_participation_interaction" do
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

    context "interacting" do
      before do
        @environment.courses.reload
        @space = Factory(:space, :owner => @environment.owner,
                         :course => @environment.courses.first)
        @course.spaces.reload

        activate_authlogic
        UserSession.create @user

        @course.join(@user, Role[:environment_admin])
      end

      it "should generate error with invalid range of time" do
        @params = { :course_id => @course.id,
                    :teacher_id => @course.teachers.first.id,
                    :date_start => "2012-03-01",
                    :date_end => "2012-02-10",
                    :spaces => [@space.id.to_s],
                    :format => :json,
                    :locale => "pt-BR" }

        get :teacher_participation_interaction, @params

        body = JSON.parse(response.body)
        err = body['error']
        err.should eq("Intervalo de tempo inválido")
      end

      it "should generate error if there is no teacher" do
        @params = { :course_id => @course.id,
                    :date_start => "2012-03-01",
                    :date_end => "2012-03-10",
                    :spaces => [@space.id.to_s],
                    :format => :json,
                    :locale => "pt-BR" }

        get :teacher_participation_interaction, @params

        body = JSON.parse(response.body)
        err = body['error']
        err.should eq("Não existem professores neste curso")
      end

      it "should generate error if there is no space" do
        @params = { :course_id => @course.id,
                    :teacher_id => @course.teachers.first.id,
                    :date_start => "2012-03-01",
                    :date_end => "2012-03-10",
                    :format => :json,
                    :locale => "pt-BR" }

        get :teacher_participation_interaction, @params

        body = JSON.parse(response.body)
        err = body['error']
        err.should eq("Não existem disciplinas no curso")
      end

      it "should return any data if format is not json" do
        @params = { :course_id => @course.id,
                    :teacher_id => @course.teachers.first.id,
                    :date_start => "2012-03-01",
                    :date_end => "2012-02-10",
                    :spaces => [@space.id.to_s],
                    :format => :html,
                    :locale => "pt-BR" }

        get :teacher_participation_interaction, @params
        ActiveSupport::JSON.decode(response.body).
          should_not be_true
      end

      it "should return params correclty" do
        @params = { :course_id => @course.id,
                    :teacher_id => @course.teachers.first.id,
                    :date_start => "2012-03-01",
                    :date_end => "2012-03-10",
                    :spaces => [@space.id.to_s],
                    :format => :json,
                    :locale => "pt-BR" }

        get :teacher_participation_interaction, @params

        body = JSON.parse(response.body)
        body.should have(4).items
        lectures = body['lectures_created']
        lectures.should_not be_empty
      end

      it "should return params callback" do
        callback = "myFunct"
        @params = { :course_id => @course.id,
                    :teacher_id => @course.teachers.first.id,
                    :date_start => "2012-03-01",
                    :date_end => "2012-03-10",
                    :spaces => [@space.id.to_s],
                    :format => :json,
                    :locale => "pt-BR",
                    :callback => callback }

        get :teacher_participation_interaction, @params

        response.body.should include "#{callback}("
      end
    end
  end
end
