require "api_spec_helper"

describe "Statuses" do
  before do
    @application, @current_user, @token = generate_token
  end

  context "when Activity type qualquecoisa" do
    before do
      @activity = Factory(:activity)
    end

    it "should return status 200 (ok)" do
      get "/api/statuses/#{@activity.id}", :oauth_token => @token, :format => 'json'
      response.code.should == '200'
    end

    it "should have id, text, created_at, links and type" do
      get "/api/statuses/#{@activity.id}", :oauth_token => @token, :format => 'json'
      %w(id text created_at links type).each do |attr|
        parse(response.body).should have_key attr
      end
    end

    it "should have the correct links (statusable, user, self)" do
      get "/api/statuses/#{@activity.id}", :oauth_token => @token, :format => 'json'
      @entity = parse(response.body)

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
#     Assim que seminar for adicionado quanto o tipo for Answer testar o link
#       para statusable
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

  context "when Activity type" do
    before do
      @activity = Factory(:activity)
      get "/api/statuses/#{@activity.id}", :oauth_token => @token, :format => 'json'
      @entity = parse(response.body)
    end
    
    it "should have a link to its Answers" do
      get href_to('answers', @entity), :format => 'json', :oauth_token => @token
      response.code.should == "200"
    end
    
    it "should have id, type, created_at, text" do
      %w(id type created_at text).each do |attr|
        @entity.should have_key attr
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

  context "when listing User statuses" do
    before do
#   É criado status para usuarios diferentes para se testar o retorno corretor
#     apartir da filtragem por tipo
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

  context "when listing space statuses" do
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

  context "when listing lectures statuses" do
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
  
  context "post /api/users/:user_id/statuses" do
    before do
      @user = Factory(:user)
      
      @params = { 'status' => { :text => 'Ximbica', :statusable_id => @user.id, 
        :statusable_type => @user.class },
        :oauth_token => @token, :format => 'json' }
        
    end
    
    it "should create an status the user type activity and return 201" do
      @params['status'][:type] = 'Activity'
      post "/api/users/#{@user.id}/statuses", @params
      
      response.code.should == "201"
    end
    
    xit "should return 422 when invalid type" do
      @params['status'][:type] = "Indevido"
      post "api/users/#{@user.id}/statuses", @params
      
      debugger
      response.code.should == "422"
    end
  end
  
  context "delete /api/users/:user_id/statuses" do    
    it "should return status 200"
    it "should return status 404 when doesnt exist"
  end
  
  context "post /api/spaces/:space_id/statuses" do
    before do
      @space = Factory(:space)
      @params = { 'status' => { :text => "Space Ximbica",
        :statusable_id => @space.id, :statusable_type => @space.class },
        :oauth_token => @token, :format => 'json' }
    end
    
    it "should create an status the space type activity and return 201" do
      @params['status'][:type] = "Activity"
      post "/api/spaces/#{@space.id}/statuses", @params
      
      response.code.should == "201"
    end
    
    it "should return 422 when invalid"
  end
  
  context "delete api/spaces/:space_id/statuses" do
  end
  
  context "post /api/lectures/:lecture_id/statuses" do
    before do
      @lecture = Factory(:lecture)
      @params = { 'status' => { :text => "Lacture Ximbica",
        :statusable_id => @lecture.id, :statusable_type => @lecture.class },
        :oauth_token => @token, :format => 'json' }
    end
    
    it "should create an status the lecture type activity and return 201" do
      @params['status'][:type] = "Activity"
      post "/api/lectures/#{@lecture.id}/statuses", @params
      
      response.code.should == "201"
    end
    
    it "should create an status the lecture type help and return 201" do
      @params['status'][:type] = "Help"
      post "/api/lectures/#{@lecture.id}/statuses", @params
      
      response.code.should == "201"
    end
    
    it "should return 422 when invalid"
  end
  
  context "delete /api/lectures/:lecture_id/statuses" do
  end
  
  context "post /api/statuses/status_id/statuses Answer type" do
    before do
      @status = Factory(:answer)
      @params = {'status' => {:text => "Ximbica Answer",
        :statusable_id => @status.id, :statusable_type => @status.class },
        :oauth_token => @token, :format => 'json' }
    end
    
    it "should return status 201 when successful" do
      @params['status'][:type] = "Answer"
      post "/api/statuses/#{@status.id}/answers", @params
      
      response.code.should == "201"
    end
    
    it "should return 422 when invalid"
  end
  
  context "delete api/statuses/:statuses_id/statuses" do
  end
end
