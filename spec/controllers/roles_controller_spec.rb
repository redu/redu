# -*- encoding : utf-8 -*-
require "spec_helper"
require 'authlogic/test_case'

describe RolesController do
  before do
    @environment = FactoryGirl.create(:environment)
    @owner = @environment.owner
    FactoryGirl.create(:course, path: "path")
    @courses = []
    @courses << FactoryGirl.create(:course, :environment => @environment,
                             :owner => @owner, path: "path")
    @courses << FactoryGirl.create(:course, :environment => @environment,
                             :owner => @owner)
    @spaces = 2.times.collect do
      FactoryGirl.create(:space, :course => @course, :owner => @owner )
    end
    @member = FactoryGirl.create(:user)
    @courses.each { |c| c.join(@member) }

    login_as @owner
  end

  context "on Environment" do
    context "with a moderated course" do
      it "should aprove user into every course if he is admin" do
        moderated_course = FactoryGirl.create(:course, :environment => @environment,
          :owner => @owner)
        moderated_course.subscription_type = 0
        moderated_course.save

        put :update, :environment_id => @environment.path, :user_id => @member.login,
        :role => Role[:environment_admin], :locale => "pt-BR"
        @member.get_association_with(moderated_course).should be_approved
      end

    end

    it "should turn the user into environment_admin" do
      put :update, :environment_id => @environment.path, :user_id => @member.login,
        :role => Role[:environment_admin], :locale => "pt-BR"

      @courses.each do |c|
        @member.get_association_with(c).role.should be_environment_admin
      end
    end

    it "should turn admin into member" do
      put :update, :environment_id => @environment.path, :user_id => @member.login,
        :role => Role[:member], :locale => "pt-BR"

      @courses.each do |c|
        @member.get_association_with(c).role.should be_member
      end
    end
  end

  context "on Course" do

    it "should turn member into teacher" do
      put :update, :environment_id => @environment.path,
        :course_id => @courses.first.path, :user_id => @member.login,
        :role => Role[:teacher], :locale => "pt-BR"

      @member.get_association_with(@courses.first).role.should be_teacher
    end

    it "should turn member into tutor" do
      put :update, :environment_id => @environment.path,
        :course_id => @courses.first.path, :user_id => @member.login,
        :role => Role[:tutor], :locale => "pt-BR"

      @member.get_association_with(@courses.first).role.should be_tutor
    end

    it "should change the role just on the specified course" do
      put :update, :environment_id => @environment.path,
        :course_id => @courses.first.path, :user_id => @member.login,
        :role => Role[:teacher], :locale => "pt-BR"

      @member.get_association_with(@courses.last).role.should be_member
    end

    it "should not turn environment_admin into anything" do
      put :update, :environment_id => @environment.path,
        :course_id => @courses.first.path, :user_id => @owner.login,
        :role => Role[:teacher], :locale => "pt-BR"

      @owner.get_association_with(@courses.first).role.should be_environment_admin
    end
  end

  context 'when a commom member is logged in' do
    before do
      login_as @member
    end

    it 'Roles#index should not be accessible' do
      get :index, :environment_id => @environment.to_param,
        :user_id => @member.to_param, :locale => 'pt-BR'

      response.should_not be_success
    end
  end
end
