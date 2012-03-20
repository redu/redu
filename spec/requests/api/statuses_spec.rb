require "api_spec_helper"

describe "Statuses" do
  before do
    @activity = Factory(:activity)
    @application, @current_user, @token = generate_token
  end

  it "should return status 200 (ok)" do
    get "/api/statuses/#{@activity.id}", :token => @token, :format => 'json'
    response.code.should == '200'
  end

  it "should have id, text, created_at, links and type" do
    get "/api/statuses/#{@activity.id}", :token => @token, :format => 'json'
    %w(id text created_at links type).each do |attr|
      parse(response.body).should have_key attr
    end
  end

  it "should have the correct links (statusable, user, self)" do
    get "/api/statuses/#{@activity.id}", :token => @token, :format => 'json'
    @entity = parse(response.body)

    %w(statusable self user).each do |attr|
      get href_to(attr, @entity), :format => 'json', :token => @token
      response.code.should == "200"
    end
  end

  context "when Answer type" do
    before do
      @answer = Factory(:answer)
      get "/api/statuses/#{@answer.id}", :format => 'json', :token => @token
      @entity = parse(response.body)
    end
    
    it "should return code 200" do
      response.code.should == "200"
    end

    it "should have a link to activity (in_response_to)" do
      link = @entity["links"].detect { |link| link['rel'] == 'in_response_to' }
      get link['href'], :format => 'json', :token => @token
      response.code.should == '200'
    end
    
    it "should have type, text, created_at" do
      %w(type text created_at).each do |attr|
        parse(response.body).should have_key attr
      end
    end
    
    it "should have the correct links (self, user, in_response_to)" do
#   Devido a funcionalidade de :statusable, :factory => :seminar_youtube
#    em answer_factory ainda não esta disponivel para api
#     statusable não esta sendo testado porém será incluiso em breve
      %w(self user in_response_to).each do |attr|
        get href_to(attr, @entity), :format => 'json', :token => @token
        response.code.should == "200"
      end
    end
    
  end

  context "when Log type" do
    before do
      @log = Factory(:log)
      get "/api/statuses/#{@log.id}", :token => @token, :format => 'json'
      @entity = parse(response.body)
    end
    
    it "should return code 200" do
      response.code.should == "200"
    end
    
    it "should have type, created_at" do
      %w(type created_at).each do |attr|
        parse(response.body).should have_key attr
      end
    end

    it "should have the correct link to statusable, self, user, logeable" do
      %w(statusable self user logeable).each do |attr|
        get href_to(attr, @entity), :format => 'json', :token => @token
        response.code.should == "200"
      end
    end
  end

  context "when Activity type" do
    before do
      @activity = Factory(:activity)
      get "/api/statuses/#{@activity.id}", :token => @token, :format => 'json'
      @entity = parse(response.body)
    end
    
    it "should have a link to its Answers" do
      %w(answers).each do |attr|
        get href_to(attr, @entity), :format => 'json', :token => @token
        response.code.should == "200"
      end
    end
  end
  
  context "when Help type" do
    before do
      @help =  Factory(:help)
      get "api/statuses/#{@help.id}", :token => @token, :format => 'json'
      @entity = parse(response.body)
    end
    
    it "should have type, text, created_at" do
      %w(type text created_at).each do |attr|
        @entity.should have_key attr
      end
    end
    
    it "should have a link statusable, self, user" do
      %w(statusable self user).each do |attr|
        get href_to(attr, @entity), :token => @token, :format => 'json'
        response.code.should == "200"
      end
    end
  end

  context "when listing User statuses" do
    before do
      @user = Factory(:user)
      @user_statuses = 4.times.collect do
        [ Factory(:help, :user => @user),
        Factory(:activity, :user => @user),
        Factory(:log, :user => @user) ]
      end.flatten
      3.times.each do
        @help = Factory(:help)
        @log = Factory(:log)
      end
    end

    it "should return code 200" do
      get "/api/users/#{@user.id}/statuses",:token => @token, :format => 'json'
      response.code.should == "200"
    end
    
    it "should return correct numbers statuses" do
      get "/api/users/#{@user.id}/statuses",:token => @token, :format => 'json'
      parse(response.body).count.should == @user_statuses.length
    end

    it "should filter by status type (help)" do
      get "/api/users/#{@user.id}/statuses", :type => "help",
        :token => @token, :format => 'json'
      parse(response.body).all? { |s| s["type"] == "Help" }.should be
    end
    
    it "should return correct numbers of statuses (Log)" do
      get "/api/users/#{@user.id}/statuses", :type => "log",
        :token => @token, :format => 'json'
      parse(response.body).count.should == 4
    end

    it "should filter by status type (log)" do
      get "/api/users/#{@user.id}/statuses", :type => "log",
        :token => @token, :format => 'json'
      parse(response.body).all? { |s| s["type"] == "Log" }.should be
    end
    
    it "should filter by status type (activity)" do
      get "api/users/#{@user.id}/statuses", :type => "activity",
        :token => @token, :format => 'json'
      parse(response.body).all? { |s| s["type"] == "Activity" }.should be
    end
  end

  context "when listing space statuses" do
    before do
      @space = Factory(:space)
    end
    
    it "should return code 200" do
      get "api/spaces/#{@space.id}/statuses", :token => @token, :format => 'json'
      response.code.should == "200"
    end
    
    it "should filter by status type (help)" do
      get "api/spaces/#{@space.id}/statuses", :type => 'help',
        :token => @token, :format => 'json'
      parse(response.body).all? { |s| s["type"] == "Help" }.should be
    end
    
    it "should filter by status type (log)" do
      get "api/spaces/#{@space.id}/statuses", :type => 'log',
        :token => @token, :format => 'json'
      parse(response.body).all? { |s| s["type"] == "Log" }.should be
    end
    it "should filter by status type (activity)" do
      get "api/spaces/#{@space.id}/statuses", :type => 'activity',
        :token => @token, :format => 'json'
      parse(response.body).all? { |s| s["type"] == "Activity" }.should be
    end
  end

  context "when listing lectures statuses" do
    before do
      @lecture = Factory(:lectore)
    end
    
    it "should return code 200"
    it "should filter by status type (help)"
    it "should filter by status type (log)"
    it "should filter by status type (activity)"
  end
end
