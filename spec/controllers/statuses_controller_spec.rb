require 'spec_helper'
require 'authlogic/test_case'

describe StatusesController do
  include Authlogic::TestCase

  subject { Factory(:activity) }

  describe "POST create" do
    context "when creating new activity" do
      before do
        @statusable = Factory(:user)
        @author = Factory(:user)
        @statusable.be_friends_with(@author)
        @author.be_friends_with(@statusable)

        # Logando
        activate_authlogic
        UserSession.create @author

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
          request.env["HTTP_REFERER"] = user_url(@statusable)
          post :create, @params
        }.should change(Status, :count).by(1)
      end

      context "without proper authorization" do
        before do
          @author.destroy_friendship_with(@statusable)
          @statusable.settings.view_mural = Privacy[:friends]
          @statusable.settings.save
        end

        it "cannot create successfully" do
          expect {
            request.env["HTTP_REFERER"] = user_url(@statusable)
            post :create, @params
          }.should_not change(Activity, :count)
        end
      end

      context "with an associated resource" do
        before do
          @resource = Factory.build(:status_resource)
          @params[:status][:status_resources_attributes] = [{
            :provider => @resource.provider,
            :thumb_url => @resource.thumb_url,
            :title => @resource.title,
            :description => @resource.description,
            :link => @resource.link
          }]
        end

        it "should create successfully" do
          request.env["HTTP_REFERER"] = user_url(@statusable)
          post :create, @params
          Status.last.status_resources.should_not be_empty
          Status.last.status_resources[0].provider.should eq(@resource.provider)
        end

        context "and status resource is invalid" do
          before do
            @params[:status][:status_resources_attributes].first.store(:link, nil)
          end

          it "should no create an status" do
            request.env["HTTP_REFERER"] = user_url(@statusable)
            expect {
              post :create, @params
            }.should_not change(Activity, :count)
          end
        end
      end
    end

    context "when creating new help request" do
      before do
        User.maintain_sessions = false
        @space = Factory(:space)
        @author = Factory(:user)
        activate_authlogic
        @subject = Factory(:subject, :owner => @author,
                           :space => @space, :finalized => true, :visible => true)
        @statusable = Factory(:lecture, :owner => @author, :subject => @subject)
        @space.course.join(@author, Role[:teacher])

        # Logando
        UserSession.create @author

        @params = {"status" => {"statusable_type"=>"Lecture", "text"=>"Lorem ipsum dolor sit amet, consectetur magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation", "statusable_id"=> @statusable.id, "type" => "Help" }, "locale" => "pt-BR"}
      end

      it "creates successfully" do
        expect {
          request.env["HTTP_REFERER"] = \
            space_subject_lecture_url(@space, @subject, @statusable)
          post :create, @params
        }.should change(Help, :count).by(1)
      end
    end
  end

  describe "POST respond" do
    context "when responding an activity" do
      before do
        @statusable = Factory(:user)
        @author = Factory(:user)
        @statusable.be_friends_with(@author)
        @author.be_friends_with(@statusable)

        # Logando
        activate_authlogic
        UserSession.create(@author)

        @params = {:id => subject.id, "status" => { "in_response_to_type"=>"Activity", "text"=>"Lorem ipsum dolor sit amet, consectetur magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation", "in_response_to_id"=> subject.id, "type"=>"Answer" }, "locale" => "pt-BR"}
      end

      it "creates successfully" do
        expect {
          request.env["HTTP_REFERER"] = user_url(@statusable)
          post :respond, @params
        }.should change(subject.answers, :count).by(1)

      end
    end

    context "when responding a help request" do
      before do
        User.maintain_sessions = false
        @space = Factory(:space)
        @author = Factory(:user)
        activate_authlogic
        @subject = Factory(:subject, :owner => @author,
                           :space => @space, :finalized => true, :visible => true)
        @lecture = Factory(:lecture, :owner => @author, :subject => @subject)
        @help = Factory(:help, :statusable => @lecture)
        @space.course.join(@author, Role[:teacher])

        # Logando
        activate_authlogic
        UserSession.create @author

        @params = {:id => @help.id,
                   "status" => { "in_response_to_type"=>"Status",
                                 "text"=>"Lorem ipsum dolor sit amet, ",
                                 "in_response_to_id"=> @help.id,
                                 "type"=>"Answer" }, "locale" => "pt-BR"}
      end

      it "creates successfully" do
        expect {
          request.env["HTTP_REFERER"] = \
            space_subject_lecture_url(@space, @subject, @lecture)
          post :respond, @params
        }.should change(@help.answers, :count).by(1)
      end
    end
  end

  describe "DELETE destroy" do
    context "when destroying a status" do
      before do
        # Logando
        activate_authlogic
        UserSession.create subject.user

        @params = {:id => subject.id, :format => "js", :locale => "pt-BR"}
      end

      it "destroys successfully" do
        expect {
          delete :destroy, @params
        }.should change(Activity, :count).by(-1)
      end

      context "that has an associated resource" do
        before do
          subject.type = "Activity"
          subject.status_resources << Factory(:status_resource, :status => subject)
          @params = {:id => subject.id, :format => "js", :locale => "pt-BR"}
        end

        it "should destroys the status successfully" do
          expect {
            delete :destroy, @params
          }.should change(Status, :count).by(-1)
        end

        it "should destroys the status resource successfully" do
          expect {
            delete :destroy, @params
          }.should change(StatusResource, :count).by(-1)
        end
      end
    end
  end
end
