require "api_spec_helper"

describe "Statuses" do
  before do
    @application, @current_user, @token = generate_token
  end

  context "when Activity type" do
    before do
      @activity = Factory(:activity)
      get "/api/statuses/#{@activity.id}", :oauth_token => @token, :format => 'json'
      @entity = parse(response.body)
    end

    it "should return status 200 (ok)" do
      response.code.should == '200'
    end

    it "should have id, text, created_at, links and type" do
      %w(id text created_at links type).each do |attr|
        @entity.should have_key attr
      end
    end

    it "should have a link to its Answers" do
      get href_to('answers', @entity), :format => 'json', :oauth_token => @token
      response.code.should == "200"
    end

    it "should have the correct links (statusable, user, self)" do
      %w(statusable self user).each do |attr|
        get href_to(attr, @entity), :format => 'json', :oauth_token => @token
        response.code.should == "200"
      end
    end
  end

  context "when Answer type" do
    before do
      @answer = Factory(:answer)
      get "/api/statuses/#{@answer.id}", :format => 'json', :oauth_token => @token
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
    
    it "should have the currect links (self, user, in_response_to)" do
#     https://github.com/redu/redu/issues/660
      %w(self user in_response_to).each do |attr|
        get href_to(attr, @entity), :oauth_token => @token, :format => 'json'
        response.code.should == "200"
      end
    end
  end

  context "when Log type" do
    before do
      @log = Factory(:log)
      get "/api/statuses/#{@log.id}", :oauth_token => @token, :format => 'json'
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
        get href_to(attr, @entity), :format => 'json', :oauth_token => @token
        response.code.should == "200"
      end
    end
  end
  
  context "when Help type" do
    before do
      @help =  Factory(:help)
      get "/api/statuses/#{@help.id}", :oauth_token => @token, :format => 'json'
      @entity = parse(response.body)
    end
    
    it "should have type, text, created_at" do
      %w(type text created_at).each do |attr|
        @entity.should have_key attr
      end
    end
    
    it "should have a link statusable, self, user" do
      %w(statusable self user).each do |attr|
        get href_to(attr, @entity), :oauth_token => @token, :format => 'json'
        response.code.should == "200"
      end
    end
  end

  context "when listing User" do
  # São criados usuarios para validação na filtragem pelo tipo
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
        @activity = Factory(:activity)
      end
    end

    it "should return code 200" do
      get "/api/users/#{@user.id}/statuses",:oauth_token => @token, :format => 'json'
      response.code.should == "200"
    end
    
    it "should return correct numbers statuses" do
      get "/api/users/#{@user.id}/statuses",:oauth_token => @token, :format => 'json'
      parse(response.body).count.should == @user_statuses.length
    end

    it "should return correct numbers of statuses (help)" do
      get "/api/users/#{@user.id}/statuses", :type => "help",
        :oauth_token => @token, :format => 'json'
      parse(response.body).count.should == 4
    end
    
    it "should filter by status type (help)" do
      get "/api/users/#{@user.id}/statuses", :type => "help",
        :oauth_token => @token, :format => 'json'
      parse(response.body).all? { |s| s["type"] == "Help" }.should be
    end
    
    it "should return correct numbers of statuses (Log)" do
      get "/api/users/#{@user.id}/statuses", :type => "log",
        :oauth_token => @token, :format => 'json'
      parse(response.body).count.should == 4
    end

    it "should filter by status type (log)" do      
      get "/api/users/#{@user.id}/statuses", :type => "log",
        :oauth_token => @token, :format => 'json'
      parse(response.body).all? { |s| s["type"] == "Log" }.should be
    end
    
    it "should filter by status type (activity)" do
      get "/api/users/#{@user.id}/statuses", :type => "activity",
        :oauth_token => @token, :format => 'json'
      parse(response.body).all? { |s| s["type"] == "Activity" }.should be
    end
    
    it "should return correct numbers of statuses (Activity)" do
      get "/api/users/#{@user.id}/statuses", :type => 'activity',
        :oauth_token => @token, :format => 'json'
      parse(response.body).count.should == 4
    end
  end

  context "when listing Space" do
    before do
      @space = Factory(:space)
    end
    
    it "should return code 200" do
      get "/api/spaces/#{@space.id}/statuses", :oauth_token => @token, :format => 'json'
      response.code.should == "200"
    end
    
    it "should filter by status type (help)" do
      get "/api/spaces/#{@space.id}/statuses", :type => 'help',
        :oauth_token => @token, :format => 'json'
      parse(response.body).all? { |s| s["type"] == "Help" }.should be
    end
    
    it "should filter by status type (log)" do
      get "/api/spaces/#{@space.id}/statuses", :type => 'log',
        :oauth_token => @token, :format => 'json'
      parse(response.body).all? { |s| s["type"] == "Log" }.should be
    end
    it "should filter by status type (activity)" do
      get "/api/spaces/#{@space.id}/statuses", :type => 'activity',
        :oauth_token => @token, :format => 'json'
      parse(response.body).all? { |s| s["type"] == "Activity" }.should be
    end
  end

  context "when listing Lectures" do
    before do
      @lecture = Factory(:lecture)
    end
    
    it "should return code 200" do
      get "/api/lectures/#{@lecture.id}/statuses", :oauth_token => @token,
        :format => 'json'
        response.code.should == "200"
    end
    
    it "should filter by status type (help)" do
      get "/api/lectures/#{@lecture.id}/statuses", :type => 'help' ,
        :oauth_token => @token, :format => 'json'
      parse(response.body).all? { |s| s["type"] == "Help" }.should be
    end
    
    it "should filter by status type (log)" do
      get "/api/lectures/#{@lecture.id}/statuses", :type => 'log' ,
        :oauth_token => @token, :format => 'json'
      parse(response.body).all? { |s| s["type"] == "Log" }.should be
    end
    
    it "should filter by status type (activity)" do
      get "/api/lectures/#{@lecture.id}/statuses", :type => 'activity',
        :oauth_token => @token, :format => 'json'
      
      parse(response.body).all? { |s| s["type"] == "Activity" }.should be
    end
  end
  
  context "when create status an user" do
    before do
      @user = Factory(:user)
      
      @params = { 'status' => { :text => 'Ximbica' },
        :oauth_token => @token, :format => 'json' }
    end
    
    it "should create an status the user type activity and return 201" do
      post "/api/users/#{@user.id}/statuses", @params
      
      response.code.should == "201"
    end
    
    it "should create status with the correct statusable" do
      post "/api/users/#{@user.id}/statuses", @params

      get href_to("statusable", parse(response.body)), :oauth_token => @token,
        :format => 'json'
      response.code.should == "200"
    end
    
    it "should create an activity" do
      post "/api/users/#{@user.id}/statuses", @params
      
      parse(response.body)["type"].should == "Activity"
    end

    it "should return 422 when invalid" do
      @params['status'][:text] = ""
      post "api/users/#{@user.id}/statuses", @params

      response.code.should == "422"
    end
  end

  context "when delete status" do
  
    it "should return status 200 when activity type" do
      @activity = Factory(:activity)
      delete "/api/statuses/#{@activity.id}", :oauth_token => @token,
       :format => 'json'

      response.status.should == 200
    end

    it "should return status 200 when help type" do
      @help = Factory(:help)
      delete "/api/statuses/#{@help.id}", :oauth_token => @token,
        :format => 'json'
        
      response.status.should == 200
    end
    
    it "should return status 200 when log type" do
      @log = Factory(:log)
      delete "/api/statuses/#{@log.id}", :oauth_token => @token, 
        :format => 'json'

      response.status.should == 200
    end

    it "should return status 200 when answer type" do
      @answer = Factory(:answer)
      delete "/api/statuses/#{@answer.id}", :oauth_token => @token,
        :format => 'json'

      response.status.should == 200
    end
    
    it "should return status 404 when not found" do
      @activity = Factory(:activity)
      delete "/api/statuses/#{@activity.id}", :oauth_token => @token, 
        :format => 'json'

      delete "/api/statuses/#{@activity.id}", :oauth_token => @token, 
        :format => 'json'
        # id valido porém já removido
      response.status.should == 404
    end
    
    it "should return status 404 when not exist" do
      delete "/api/statuses/007", :oauth_token => @token, :format => 'json'
      
      response.status.should == 404
    end
  end

  context "when create status an space" do
    before do
      @space = Factory(:space)
      @params = { 'status' => { :text => "Space Ximbica" },
        :oauth_token => @token, :format => 'json' }
    end
    
    it "should create an status the space type activity and return 201" do
      post "/api/spaces/#{@space.id}/statuses", @params

      response.code.should == "201"
    end
    
    it "should create status with the correct statusable" do
      post "/api/spaces/#{@space.id}/statuses", @params
      
      get href_to("statusable", parse(response.body)), :oauth_token => @token,
        :format => 'json'
      response.code.should == "200"
    end
    
    it "should create an activity" do
      post "/api/spaces/#{@space.id}/statuses", @params
      
      parse(response.body)["type"].should == "Activity" 
    end
    
    it "should return 422 when invalid" do
      @params['status'][:text] = ""
      post "/api/spaces/#{@space.id}/statuses", @params
      
      response.code.should == "422"
    end
  end

  context "when create status an lecture" do
    before do
      @lecture = Factory(:lecture)
      @params = { 'status' => { :text => "Lacture Ximbica" },
        :oauth_token => @token, :format => 'json' }
    end
    
    it "should create an status the lecture type activity and return 201" do
      @params['status'][:type] = "Activity"
      post "/api/lectures/#{@lecture.id}/statuses", @params

      response.code.should == "201"
    end
    
    it "should create an activity" do
      @params['status'][:type] = "Activity"
      post "/api/lectures/#{@lecture.id}/statuses", @params
      
      parse(response.body)["type"].should == "Activity"
    end
    
    it "should create status with the corret statusable when type activity" do
      @params['status'][:type] = "activity"
      post "/api/lectures/#{@lecture.id}/statuses", @params

      get href_to("statusable", parse(response.body)), :oauth_token => @token,
        :format => 'json'
      response.code.should == "200"
    end
    
    it "should create an activity when no passed type" do  
      @params['status'][:type] = ""
      post "/api/lectures/#{@lecture.id}/statuses", @params
      
      parse(response.body)["type"].should == "Activity"
    end
    
    it "should create an status the lecture type help and return 201" do
      @params['status'][:type] = "Help"
      post "/api/lectures/#{@lecture.id}/statuses", @params
      
      response.code.should == "201"
    end
    
    it "should create an help" do
      @params['status'][:type] = "Help"
      post "/api/lectures/#{@lecture.id}/statuses", @params
      
      parse(response.body)["type"].should == "Help"
    end
    
    it "should create status with the corret statusable when type help" do
      @params['status'][:type] = "help"
      post "/api/lectures/#{@lecture.id}/statuses", @params

      get href_to("statusable", parse(response.body)), :oauth_token => @token,
        :format => 'json'
      response.code.should == "200"
    end
    
    it "should return 422 when invalid" do
      @params['status'][:text] = ""
      post "/api/lectures/#{@lecture.id}/statuses", @params
      
      response.code.should == "422"
    end
  end

  context "when create status an answer" do
    before do
      @params = {'status' => {:text => "Ximbica Answer Test" },
        :oauth_token => @token, :format => 'json' }
    end

    it "should create status 201 when activity type" do
      @activity = Factory(:activity)
      post "/api/statuses/#{@activity.id}/answers", @params

      response.code.should == "201"
    end
    
    it "should create an activity" do
      @activity = Factory(:activity)
      post "/api/statuses/#{@activity.id}/answers", @params

      parse(response.body)["type"].should == "Answer"
    end
    
    it "should create status 201 when help type" do
      @help = Factory(:help)
      post "/api/statuses/#{@help.id}/answers", @params

      response.code.should == "201"
    end
    
    it "should return 404 when doesnt exists" do
      post "/api/statuses/007/answers", @params # id não existente
      
      response.code.should == "404"
    end

    it "should return 422 when invalid" do
      @params['status'][:text] = "" # texto inválido
      @activity = Factory(:activity)
      post "/api/statuses/#{@activity.id}/answers", @params
      
      response.code.should == "422"
    end
    
    it "should return 422 when invalid type" do
      @log = Factory(:log) # tipo inválido
      post "/api/statuses/#{@log.id}/answers", @params
      
      response.code.should == "422"
    end
  end

end
