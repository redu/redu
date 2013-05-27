# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'authlogic/test_case'

describe StatusesController do
  subject { FactoryGirl.create(:activity) }
  let(:base_params) { { locale: "pt-BR" } }
  let(:author) { FactoryGirl.create(:user) }
  let(:statusable) { FactoryGirl.create(:user) }

  describe "POST create" do
    let(:params) do
      base_params.
        merge(status: {statusable_type: "User", text: "Lorem ipsum dolor",
                                    statusable_id: statusable.id,
                                    type: "Activity" })
    end
    before do
      callback_address(controller.user_url(statusable))
    end

    context "without proper authorization" do
      before do
        statusable.settings.update_attribute(:view_mural, Privacy[:friends])
      end

      it "cannot create successfully" do
        expect {
          post :create, params
        }.to_not change(Activity, :count)
      end
    end

    context "when creating new activity" do
      before do
        create_friendship(statusable, author)
        login_as author
      end

      it "creates successfully" do
        expect {
          post :create, params
        }.to change(Status, :count).by(1)
      end

      context "with an associated resource" do
        let(:resource) { FactoryGirl.build(:status_resource) }
        let(:params_with_resource) do
          params[:status][:status_resources_attributes] = [{
            provider: resource.provider,
            thumb_url: resource.thumb_url,
            title: resource.title,
            description: resource.description,
            link: resource.link
          }]
          params
        end

        it "should create successfully" do
          post :create, params_with_resource
          Status.last.status_resources.should_not be_empty
          Status.last.status_resources[0].provider.should eq(resource.provider)
        end

        it "should no create an status when resource is invalid" do
          params_with_resource[:status][:status_resources_attributes].
            first.store(:link, nil)
          expect {
            post :create, params_with_resource
          }.to_not change(Activity, :count)
        end
      end
    end

    context "when creating new help request" do
      let(:statusable) { FactoryGirl.create(:lecture, owner: author, subject: subj) }
      let(:subj) do
        FactoryGirl.create(:subject, owner: author, space: space,
                           finalized: true, visible: true)
      end
      let(:author) { FactoryGirl.create(:user) }
      let(:space) { FactoryGirl.create(:space) }
      let(:status_attrs) do
        {statusable_type: "Lecture", text: "Lorem ipsum dolor sit amet,",
         statusable_id: statusable.id, type: "Help" }
      end
      let(:params) { base_params.merge({status: status_attrs}) }

      before do
        space.course.join(author, Role[:teacher])
        login_as author
      end

      it "creates successfully" do
        expect {
          callback_address(controller.space_subject_lecture_url(space, subj, statusable))
          post :create, params
        }.to change(Help, :count).by(1)
      end
    end
  end

  describe "POST respond" do
    let(:params) do
      {id: subject.id,
       status: { in_response_to_type: "Activity",
                     text: "Lorem ipsum dolor sit amet",
                     in_response_to_id: subject.id,
                     type: "Answer" } }.merge(base_params)
    end
    before { login_as(author) }

    context "when responding an activity" do
      before do
        create_friendship(statusable, author)
      end

      it "creates successfully" do
        expect {
          callback_address(controller.user_url(statusable))
          post :respond, params
        }.to change(subject.answers, :count).by(1)
      end
    end

    context "when responding a help request" do
      let(:help) { FactoryGirl.create(:help, statusable: lecture) }
      let(:lecture) { FactoryGirl.create(:lecture, owner: author, subject: subj) }
      let(:subj) { FactoryGirl.create(:subject, owner: author, space: space, finalized: true, visible: true) }
      let(:author) { FactoryGirl.create(:user) }
      let(:space) { FactoryGirl.create(:space) }
      let(:response_params) do
        params.merge(id: help.id, "in_response_to_type"=>"Status" ,"in_response_to_id"=> help.id)
      end

      before do
        space.course.join(author, Role[:teacher])
      end

      it "creates successfully" do
        expect {
          callback_address(controller.space_subject_lecture_url(space, subj, lecture))
          post :respond, response_params
        }.to change(help.answers, :count).by(1)
      end
    end
  end

  describe "DELETE destroy" do
    let(:params) { base_params.merge(id: subject.id, format: "js") }
    context "when destroying a status" do
      before do
        login_as subject.user
      end

      it "destroys successfully" do
        expect {
          delete :destroy, params
        }.to change(Activity, :count).by(-1)
      end

      context "that has an associated resource" do
        before do
          subject.type = "Activity"
          subject.status_resources << FactoryGirl.create(:status_resource, status: subject)
        end

        it "should destroys the status successfully" do
          expect {
            delete :destroy, params
          }.to change(Status, :count).by(-1)
        end

        it "should destroys the status resource successfully" do
          expect {
            delete :destroy, params
          }.to change(StatusResource, :count).by(-1)
        end
      end
    end
  end

  def create_friendship(user, friend)
    user.be_friends_with(friend)
    friend.be_friends_with(user)
  end

  def callback_address(url)
    request.env["HTTP_REFERER"] = url
  end
end
