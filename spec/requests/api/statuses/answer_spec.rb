# -*- encoding : utf-8 -*-
require "api_spec_helper"

describe "Answer" do
  let(:current_user) { FactoryBot.create(:user) }
  let(:token) { _, _, token = generate_token(current_user); token }
  let(:activity) do
    FactoryBot.create(:activity, user: current_user, statusable: current_user)
  end
  let(:answer) do
    FactoryBot.create(:answer, statusable: current_user,
            user: current_user, in_response_to: activity)
  end
  let(:params) { { oauth_token: token, format: 'json'} }

  before do
    get "/api/statuses/#{answer.id}", params
    @entity = parse(response.body)
  end

  it "should return code 200" do
    response.code.should == "200"
  end

  it "should have type, text, created_at" do
    %w(type text created_at).each do |attr|
      parse(response.body).should have_key attr
    end
  end

  it "should have the correct links (self, user, in_response_to and statusable)" do
    %w(self user in_response_to statusable).each do |attr|
      get href_to(attr, @entity), params
      response.code.should == "200"
    end
  end

  it_should_behave_like "embeds user" do
    let(:embeder) { answer }
    let(:user) { embeder.user }
    let(:entity) { @entity }
  end

  context "when creating an Answer" do
    let(:space) do
      environment = FactoryBot.create(:complete_environment, owner: current_user)
      environment.courses.first.spaces.first
    end
    let(:lecture) do
      s = FactoryBot.create(:subject, owner: space.owner, space: space)
      FactoryBot.create(:lecture, owner: s.owner, subject: s)
    end
    let(:activity) do
      FactoryBot.
        create(:activity, user: current_user, statusable: current_user)
    end
    let(:help) do
      FactoryBot.create(:help, user: current_user, statusable: lecture)
    end
    let(:params) do
      { status: {text: "Ximbica Answer Test" },
        oauth_token: token, format: 'json' }
    end

    it "should return status 201 when activity type" do
      post "/api/statuses/#{activity.id}/answers", params
      response.code.should == "201"
    end

    it "should return a representation with Answer type" do
      post "/api/statuses/#{activity.id}/answers", params

      parse(response.body)["type"].should == "Answer"
    end

    it "should return status 201 when answering a Help" do
      post "/api/statuses/#{help.id}/answers", params

      response.code.should == "201"
    end

    it "should return 404 when activity doesnt exists" do
      # id não existente
      post "/api/statuses/007/answers", params

      response.code.should == "404"
    end

    it "should return 422 when invalid" do
      params[:status][:text] = ""
      post "/api/statuses/#{activity.id}/answers", params

      response.code.should == "422"
    end

    xit "should return 422 when invalid type" do
      @log = FactoryBot.create(:log) # tipo inválido
      post "/api/statuses/#{@log.id}/answers", @params
      # Deve ser atualizado com authorize
      response.code.should == "422"
    end

    it "should return correct statusable" do
      post "/api/statuses/#{activity.id}/answers", params

      get href_to("statusable", parse(response.body)), params
      response.code.should == "200"
    end

    it "should return corret in_response_to" do
      post "/api/statuses/#{activity.id}/answers", params

      get href_to("in_response_to", parse(response.body)), params
      response.code.should == "200"
    end

    %w(Activity Help).each do |type|
      it "should return correct in_response_to type (Activity)" do
        id = send(type.downcase).try(:id)
        post "/api/statuses/#{id}/answers", params

        get href_to("in_response_to", parse(response.body)), params
        parse(response.body)["type"].should == type
      end
    end
  end

  context "when listing Answers" do
    let(:activity) do
      FactoryBot.
        create(:activity, statusable: current_user, user: current_user)
    end
    let(:params) do
      { status: {text: "Ximbica Answer Test" },
        oauth_token: token, format: 'json' }
    end
    before do
      2.times do
        post "/api/statuses/#{activity.id}/answers", params
      end
    end

    it "should return code 200" do
      get "/api/statuses/#{activity.id}/answers", oauth_token: token,
        format: 'json'
      response.code.should == "200"
    end
  end
end
