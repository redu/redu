# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'authlogic/test_case'

describe StatusesController do
  subject { FactoryGirl.create(:activity) }

  describe "POST create" do
    context "when creating new activity" do
      before do
        @statusable = FactoryGirl.create(:user)
        @author = FactoryGirl.create(:user)
        @statusable.be_friends_with(@author)
        @author.be_friends_with(@statusable)

        login_as @author

        @params = {
          :status => {:statusable_type => "User",
                      :text => "Lorem ipsum dolor sit amet, consectetur" +
                               "magna aliqua. Ut enim ad minim veniam," +
                               "quis nostrud exercitation",
                      :statusable_id => @statusable.id,
                      :type => "Activity" },
          :locale => "pt-BR"
        }
      end

      it "creates successfully" do
        expect {
          request.env["HTTP_REFERER"] = controller.user_url(@statusable)
          post :create, @params
        }.to change(Status, :count).by(1)
      end

      context "without proper authorization" do
        before do
          @author.destroy_friendship_with(@statusable)
          @statusable.settings.view_mural = Privacy[:friends]
          @statusable.settings.save
        end

        it "cannot create successfully" do
          expect {
            request.env["HTTP_REFERER"] = controller.user_url(@statusable)
            post :create, @params
          }.to_not change(Activity, :count)
        end
      end

      context "with an associated resource" do
        before do
          @resource = FactoryGirl.build(:status_resource)
          @params[:status][:status_resources_attributes] = [{
            :provider => @resource.provider,
            :thumb_url => @resource.thumb_url,
            :title => @resource.title,
            :description => @resource.description,
            :link => @resource.link
          }]
        end

        it "should create successfully" do
          request.env["HTTP_REFERER"] = controller.user_url(@statusable)
          post :create, @params
          Status.last.status_resources.should_not be_empty
          Status.last.status_resources[0].provider.should eq(@resource.provider)
        end

        context "and status resource is invalid" do
          before do
            @params[:status][:status_resources_attributes].first.store(:link, nil)
          end

          it "should no create an status" do
            request.env["HTTP_REFERER"] = controller.user_url(@statusable)
            expect {
              post :create, @params
            }.to_not change(Activity, :count)
          end
        end
      end
    end

    context "when creating new help request" do
      before do
        @space = FactoryGirl.create(:space)
        @author = FactoryGirl.create(:user)
        @subject = FactoryGirl.create(:subject, :owner => @author,
                           :space => @space, :finalized => true, :visible => true)
        @statusable = FactoryGirl.create(:lecture, :owner => @author, :subject => @subject)
        @space.course.join(@author, Role[:teacher])

        login_as @author

        @params = {"status" => {"statusable_type"=>"Lecture", "text"=>"Lorem ipsum dolor sit amet, consectetur magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation", "statusable_id"=> @statusable.id, "type" => "Help" }, "locale" => "pt-BR"}
      end

      it "creates successfully" do
        expect {
          request.env["HTTP_REFERER"] = \
            controller.space_subject_lecture_url(@space, @subject, @statusable)
          post :create, @params
        }.to change(Help, :count).by(1)
      end
    end
  end

  describe "POST respond" do
    context "when responding an activity" do
      before do
        @statusable = FactoryGirl.create(:user)
        @author = FactoryGirl.create(:user)
        @statusable.be_friends_with(@author)
        @author.be_friends_with(@statusable)

        login_as @author

        @params = {:id => subject.id, "status" => { "in_response_to_type"=>"Activity", "text"=>"Lorem ipsum dolor sit amet, consectetur magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation", "in_response_to_id"=> subject.id, "type"=>"Answer" }, "locale" => "pt-BR"}
      end

      it "creates successfully" do
        expect {
          request.env["HTTP_REFERER"] = controller.user_url(@statusable)
          post :respond, @params
        }.to change(subject.answers, :count).by(1)

      end
    end

    context "when responding a help request" do
      before do
        @space = FactoryGirl.create(:space)
        @author = FactoryGirl.create(:user)
        @subject = FactoryGirl.create(:subject, :owner => @author,
                           :space => @space, :finalized => true, :visible => true)
        @lecture = FactoryGirl.create(:lecture, :owner => @author, :subject => @subject)
        @help = FactoryGirl.create(:help, :statusable => @lecture)
        @space.course.join(@author, Role[:teacher])

        login_as @author

        @params = {:id => @help.id,
                   "status" => { "in_response_to_type"=>"Status",
                                 "text"=>"Lorem ipsum dolor sit amet, ",
                                 "in_response_to_id"=> @help.id,
                                 "type"=>"Answer" }, "locale" => "pt-BR"}
      end

      it "creates successfully" do
        expect {
          request.env["HTTP_REFERER"] = \
            controller.space_subject_lecture_url(@space, @subject, @lecture)
          post :respond, @params
        }.to change(@help.answers, :count).by(1)
      end
    end
  end

  describe "DELETE destroy" do
    context "when destroying a status" do
      before do
        login_as subject.user

        @params = {:id => subject.id, :format => "js", :locale => "pt-BR"}
      end

      it "destroys successfully" do
        expect {
          delete :destroy, @params
        }.to change(Activity, :count).by(-1)
      end

      context "that has an associated resource" do
        before do
          subject.type = "Activity"
          subject.status_resources << FactoryGirl.create(:status_resource, :status => subject)
          @params = {:id => subject.id, :format => "js", :locale => "pt-BR"}
        end

        it "should destroys the status successfully" do
          expect {
            delete :destroy, @params
          }.to change(Status, :count).by(-1)
        end

        it "should destroys the status resource successfully" do
          expect {
            delete :destroy, @params
          }.to change(StatusResource, :count).by(-1)
        end
      end
    end
  end
end
