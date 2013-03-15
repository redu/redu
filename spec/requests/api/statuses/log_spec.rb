require "api_spec_helper"

describe "Log" do
  let(:current_user) { Factory(:user) }
  let(:token) { _, _, token = generate_token(current_user); token }
  let(:space) do
    environment = Factory(:complete_environment, :owner => current_user)
    environment.courses.first.spaces.first
  end
  let(:log) do
    Factory(:log, :statusable => space, :user => current_user,
            :logeable => space)
  end
  let(:params) { { :oauth_token => token, :format => 'json'} }


  context "when GET /api/statuses/:id (type log)" do
    before do
      get "/api/statuses/#{log.id}", params
      @entity = parse(response.body)
    end

    it "should return code 200" do
      response.code.should == "200"
    end

    it "should have type, created_at and text" do
      %w(type created_at text logeable_type).each do |attr|
        @entity.should have_key attr
      end
    end

    it "should have the correct link to statusable, self, user and logeable" do
      %w(statusable self user logeable).each do |attr|
        get href_to(attr, @entity), params
        response.code.should == "200"
      end
    end

    it_should_behave_like "embeds user" do
      let(:embeder) { log }
      let(:user) { embeder.user }
      let(:entity) { @entity }
    end
  end

  context "when GET /api/users/:id/statuses" do
    let!(:user_logs) do
      2.times.collect do
        Factory(:log, :statusable => current_user, :logeable => current_user, :user => current_user)
      end
    end
    let!(:space_logs) do
      1.times.collect { Factory(:log, :statusable => current_user, :logeable => space, :user => current_user) }
    end

    it "should filter Logs by logeable_type" do
      filters = { :type => 'Log', :logeable_type => 'User' }
      get "/api/users/#{current_user.id}/statuses", params.merge(filters)
      ids = parse(response.body).collect { |status| status["id"] }
      ids.to_set.should == user_logs.collect(&:id).to_set
    end

    it "should accept multiples logeable_type filter" do
      filters = { :type => 'Log', :logeable_type => ['User', 'Space'] }
      get "/api/users/#{current_user.id}/statuses", params.merge(filters)
      ids = parse(response.body).collect { |status| status["id"] }
      ids.to_set.should == (user_logs + space_logs).flatten.collect(&:id).to_set
    end

    it "should ignore empty logeable_type filter" do
      filters = { :type => 'Log', :logeable_type => [] }
      get "/api/users/#{current_user.id}/statuses", params.merge(filters)
      ids = parse(response.body).collect { |status| status["id"] }
      ids.to_set.should == (current_user.logs + space_logs).flatten.collect(&:id).to_set
    end

    it "should work without logeable_type filter" do
      filters = { :type => 'Log' }
      get "/api/users/#{current_user.id}/statuses", params.merge(filters)
      logs = parse(response.body).select { |status| status["type"] == 'Log' }
      logs.count.should == (current_user.logs + space_logs).flatten.count
    end
  end
end
