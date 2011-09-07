require 'spec_helper'
require 'authlogic/test_case'

describe StatusesController do
  include Authlogic::TestCase

  subject { Factory(:activity) }

  context "when creating new activity" do
    before do
      @statusable = Factory(:user)
      @author = Factory(:user)
      @statusable.be_friends_with(@author)
      @author.be_friends_with(@statusable)

      # Logando
      activate_authlogic
      UserSession.create @author

        @params = {"status" => {"statusable_type"=>"User", "text"=>"Lorem ipsum dolor sit amet, consectetur magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation", "statusable_id"=> @statusable.id, "type"=>"User" }, "locale" => "pt-BR"}
    end

    it "creates successfully" do
      expect {
        request.env["HTTP_REFERER"] = user_url(@statusable)
        post :create, @params
      }.should change(Status, :count).by(1)
    end

    context "withdout proper authorization" do
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
  end

  context "when responding an activity" do
    before do
      @statusable = Factory(:user)
      @author = Factory(:user)
      @statusable.be_friends_with(@author)
      @author.be_friends_with(@statusable)

      # Logando
      activate_authlogic
      UserSession.create(@author)

      @params = {:id => subject.id, "status" => {"statusable_type"=>"User", "text"=>"Lorem ipsum dolor sit amet, consectetur magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation", "statusable_id"=> subject.id, "type"=>"Answer" }, "locale" => "pt-BR"}
    end

    it "creates successfully" do
      expect {
        post :respond, @params
      }.should change(subject.answers, :count).by(1)

    end
  end
end
