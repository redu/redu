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

    it "should have the correct links (self, user, in_response_to and statusable)" do
      %w(self user in_response_to statusable).each do |attr|
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

    it "should have type, created_at and text" do
      %w(type created_at text).each do |attr|
        @entity.should have_key attr
      end
    end

    it "should return correct statusable" do
      get href_to("statusable", @entity), :oauth_token => @token,
        :format => 'json'
      response.code.should == "200"
    end

    it "should have the correct link to statusable, self, user and logeable" do
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

    it "should have a link statusable, self, user and answers" do
      %w(statusable self user answers).each do |attr|
        get href_to(attr, @entity), :oauth_token => @token, :format => 'json'
        response.code.should == "200"
      end
    end
  end

  context "when listing on User" do
    before do
      # São criados usuarios para validação na filtragem pelo tipo
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
      get "/api/users/#{@user.id}/statuses",:oauth_token => @token,
        :format => 'json'

      parse(response.body).count.should == @user_statuses.select {|i| i[:type] ==
        "Activity" or i[:type] == "Help"}.length
    end

    it "should filter by status type (help)" do
      get "/api/users/#{@user.id}/statuses", :type => "help",
        :oauth_token => @token, :format => 'json'
      parse(response.body).all? { |s| s["type"] == "Help" }.should be
    end

    it "should return correct numbers of statuses (Help)" do
      get "/api/users/#{@user.id}/statuses", :type => "help",
        :oauth_token => @token, :format => 'json'
      parse(response.body).count.should == @user_statuses.select {|i| i[:type] == "Help" }.length
    end

    it "should return correct numbers of statuses (Log)" do
      get "/api/users/#{@user.id}/statuses", :type => "log",
        :oauth_token => @token, :format => 'json'
      parse(response.body).count.should == @user_statuses.select {|i| i[:type] == "Log" }.length
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
      parse(response.body).count.should == @user_statuses.select {|i| i[:type] == "Activity" }.length
    end
  end

  context "when listing on Space" do
    before do
      @space = Factory(:space)
      @space_statuses = 3.times.collect do
        [ Factory(:help, :statusable => @space),
          Factory(:activity, :statusable => @space),
          Factory(:log, :statusable => @space) ]
      end.flatten
      3.times.each do
        Factory(:help)
        Factory(:activity)
        Factory(:log)
      end
    end

    it "should return code 200" do
      get "/api/spaces/#{@space.id}/statuses", :oauth_token => @token,
        :format => 'json'
      response.code.should == "200"
    end

    it "should return correct numbers statuses" do
      get "/api/spaces/#{@space.id}/statuses", :oauth_token => @token,
        :format => 'json'
      parse(response.body).count.should == @space_statuses.select {|i| i[:type] ==
       "Help" or i[:type] == "Activity" }.length
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

  context "when listing on Lecture" do
    before do
      @lecture = Factory(:lecture)
      @lecture_statuses = 3.times.collect do
        [ Factory(:help, :statusable => @lecture),
          Factory(:activity, :statusable => @lecture),
          Factory(:log, :statusable => @lecture) ]
      end.flatten
      4.times.each do
        Factory(:help)
        Factory(:activity)
        Factory(:log)
      end
    end

    it "should return code 200" do
      get "/api/lectures/#{@lecture.id}/statuses", :oauth_token => @token,
        :format => 'json'
        response.code.should == "200"
    end

    it "should return correct numbers statuses" do
      get "/api/lectures/#{@lecture.id}/statuses", :oauth_token => @token,
        :format => 'json'
      parse(response.body).count.should ==
        @lecture_statuses.select {|i| i[:type] == "Activity" or i[:type] == "Help" }.length
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

  context "when creating a status on user" do
    before do
      @user = Factory(:user)

      @params = { 'status' => { :text => 'Ximbica' },
        :oauth_token => @token, :format => 'json' }
    end

    it "should return 201" do
      post "/api/users/#{@user.id}/statuses", @params
      response.code.should == "201"
    end

    it "should create status with the correct statusable" do
      post "/api/users/#{@user.id}/statuses", @params

      get href_to("statusable", parse(response.body)), :oauth_token => @token,
        :format => 'json'
      response.code.should == "200"
    end

    it "should return statusable user" do
      post "/api/users/#{@user.id}/statuses", @params

      get href_to("statusable", parse(response.body)), :oauth_token => @token,
        :format => 'json'
      parse(response.body)["first_name"].should == @user.first_name
    end

    it "should create an activity" do
      post "/api/users/#{@user.id}/statuses", @params

      parse(response.body)["type"].should == "Activity"
    end

    it "should return 422 when invalid" do
      @params['status'][:text] = ""
      post "/api/users/#{@user.id}/statuses", @params

      response.code.should == "422"
    end
  end

  context "when deleting status" do

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

      # id valido porém já removido
      delete "/api/statuses/#{@activity.id}", :oauth_token => @token,
        :format => 'json'
      response.status.should == 404
    end

    it "should return status 404 when does not exist" do
      delete "/api/statuses/007", :oauth_token => @token, :format => 'json'
      response.status.should == 404
    end
  end

  context "when create status on space" do
    before do
      @space = Factory(:space)
      @params = { 'status' => { :text => "Space Ximbica" },
        :oauth_token => @token, :format => 'json' }
    end

    it "should return 201" do
      post "/api/spaces/#{@space.id}/statuses", @params
      response.code.should == "201"
    end

    it "should create status with the correct statusable" do
      post "/api/spaces/#{@space.id}/statuses", @params

      get href_to("statusable", parse(response.body)), :oauth_token => @token,
        :format => 'json'
      response.code.should == "200"
    end

    it "should return statusable space" do
      post "/api/spaces/#{@space.id}/statuses", @params

      get href_to("statusable", parse(response.body)), :oauth_token => @token,
        :format => 'json'
      parse(response.body)['name'].should == @space.name
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

  context "when creating status on lecture type (Activity)" do
    before do
      @lecture = Factory(:lecture)
      @params = { 'status' => { :text => "Lacture Ximbica" },
        :oauth_token => @token, :format => 'json' }
    end

    it "should return 201" do
      @params['status'][:type] = "Activity"
      post "/api/lectures/#{@lecture.id}/statuses", @params
      response.code.should == "201"
    end

    it "should return correct statusable lecture" do
      @params['status'][:type] = "Activity"
      post "/api/lectures/#{@lecture.id}/statuses", @params

      get href_to("statusable", parse(response.body)), :oauth_token => @token,
        :format => 'json'

      parse(response.body)['lecture']['name'].should == @lecture.name
    end

    it "should create an activity" do
      @params['status'][:type] = "Activity"
      post "/api/lectures/#{@lecture.id}/statuses", @params

      parse(response.body)["type"].should == "Activity"
    end

    it "should return correct statusable" do
      @params['status'][:type] = "activity"
      post "/api/lectures/#{@lecture.id}/statuses", @params

      get href_to("statusable", parse(response.body)), :oauth_token => @token,
        :format => 'json'
      parse(response.body)['lecture']['name'].should == @lecture.name
    end

    it "should create an activity when there is not type" do
      post "/api/lectures/#{@lecture.id}/statuses", @params

      parse(response.body)["type"].should == "Activity"
    end
  end

  context "when creating status on lecture type (Help)" do
    before do
      @lecture = Factory(:lecture)
      @params = { 'status' => { :text => "Lacture Ximbica" },
        :oauth_token => @token, :format => 'json' }
    end

    it "should create a status with the lecture type help and return 201" do
      @params['status'][:type] = "Help"
      post "/api/lectures/#{@lecture.id}/statuses", @params

      response.code.should == "201"
    end

    it "should create an help" do
      @params['status'][:type] = "Help"
      post "/api/lectures/#{@lecture.id}/statuses", @params

      parse(response.body)["type"].should == "Help"
    end

    it "should return statusable" do
      @params['status'][:type] = "help"
      post "/api/lectures/#{@lecture.id}/statuses", @params

      get href_to("statusable", parse(response.body)), :oauth_token => @token,
        :format => 'json'
      response.code.should == "200"
    end

    it "should return 422 when invalid" do
      @params['status'][:type] = "help"
      @params['status'][:text] = ""
      post "/api/lectures/#{@lecture.id}/statuses", @params

      response.code.should == "422"
    end
  end

  context "when creating an answer" do
    before do
      @params = {'status' => {:text => "Ximbica Answer Test" },
        :oauth_token => @token, :format => 'json' }
    end

    it "should return status 201 when activity type" do
      @activity = Factory(:activity)
      post "/api/statuses/#{@activity.id}/answers", @params
      response.code.should == "201"
    end

    it "should create an answer" do
      @activity = Factory(:activity)
      post "/api/statuses/#{@activity.id}/answers", @params

      parse(response.body)["type"].should == "Answer"
    end

    it "should return status 201 when help type" do
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

    xit "should return 422 when invalid type" do
      @log = Factory(:log) # tipo inválido
      post "/api/statuses/#{@log.id}/answers", @params
      # Deve ser atualizado com authorize
      response.code.should == "422"
    end

    it "should return correct statusable" do
      @activity = Factory(:activity)
      post "/api/statuses/#{@activity.id}/answers", @params

      get href_to("statusable", parse(response.body)), :oauth_token => @token,
        :format => 'json'
      response.code.should == "200"
    end

    it "should return corret in_response_to" do
      @activity = Factory(:activity)
      post "/api/statuses/#{@activity.id}/answers", @params

      get href_to("in_response_to", parse(response.body)), :oauth_token => @token,
        :format => 'json'
      response.code.should == "200"
    end

    it "should return correct in_response_to type (Activity)" do
      @activity = Factory(:activity)
      post "/api/statuses/#{@activity.id}/answers", @params

      get href_to("in_response_to", parse(response.body)), :oauth_token => @token,
        :format => 'json'
      parse(response.body)["type"].should == "Activity"
    end

    it "should return correct in_response_to type (Help)" do
      @help = Factory(:help)
      post "/api/statuses/#{@help.id}/answers", @params

      get href_to("in_response_to", parse(response.body)), :oauth_token => @token,
        :format => 'json'
      parse(response.body)["type"].should == "Help"
    end
  end

  context "when listing an Answer" do
    it "should return code 200 type (activity)" do
      @activity = Factory(:activity)
      get "/api/statuses/#{@activity.id}/answers", :oauth_token => @token,
        :format => 'json'
      response.code.should == "200"
    end

    it "should return code 200 type (help)" do
      @help = Factory(:help)
      get "/api/statuses/#{@help.id}/answers", :oauth_token => @token,
        :format => 'json'
      response.code.should == "200"
    end

    it "should return code 200" do
      @log = Factory(:log)
      get "/api/statuses/#{@log.id}/answers", :oauth_token => @token,
        :format => 'json'
      # lista vazia
      response.code.should == "200"
    end
  end

  context "when listing overview on Space (timeline)" do
    before do
      @space = Factory(:space)
      @params = { :oauth_token => @token, :format => 'json' }
    end

    it "should return code 200" do
      get "/api/spaces/#{@space.id}/statuses/timeline", @params
      # Retorna 200 mesmo sem nada listado
      response.code.should == "200"
    end

    it "should return text of status created on space" do
      @params = { 'status' => { :text => "Ximbica over" },
        :oauth_token => @token, :format => 'json' }
      post "/api/spaces/#{@space.id}/statuses", @params
      get "/api/spaces/#{@space.id}/statuses/timeline", @params

      parse(response.body)[0]['text'].should == "Ximbica over"
    end

    it "should not return null body" do
      @params = { 'status' => { :text => "Ximbica over" },
        :oauth_token => @token, :format => 'json' }
      post "/api/spaces/#{@space.id}/statuses", @params
      get "/api/spaces/#{@space.id}/statuses/timeline", @params

      parse(response.body).should_not be_empty
    end

    it "should return code 404 when doesnt exist" do
      get "/api/spaces/007/statuses/timeline", @params
      response.code.should == "404"
    end

    # FIXME pelo texto esse teste faz a mesma coisa do teste anterior
    it "should return code 404, not found" do
      @lecture = Factory(:lecture)
      get "/api/spaces/#{@lecture.id}/statuses/timeline", @params
      response.code.should == "404"
    end
  end

  context "when listing overview on User (timeline)" do
    before do
      @user = Factory(:user)
      # Associação do user com uma atividade
      ActiveRecord::Observer.with_observers(:status_observer) do
        @activity = Factory(:activity,
                              :user => @user,
                              :statusable => @user)

        @associations = @user.status_user_associations
        @activity.text = "Ximbica over"
        @params = { 'status' => { :text => @activity.text },
          :oauth_token => @token, :format => 'json' }

        post "/api/users/#{@user.id}/statuses", @params
      end
    end

    it "should return 200" do
      get "/api/users/#{@user.id}/statuses/timeline", @params
      response.code.should == "200"
    end

    it "should return id of status created on user" do
      get "/api/users/#{@user.id}/statuses/timeline", @params
      parse(response.body)[0]['id'].should == @activity.id
    end

    it "should not return null body" do
      get "/api/users/#{@user.id}/statuses/timeline", @params
      parse(response.body).should_not be_empty
    end

    it "should return the correct number of statuses" do
      get "/api/users/#{@user.id}/statuses/timeline", @params

      parse(response.body).count.should == @user.overview.count
    end

    it "should return code 404 doesnt exist" do
      get "/api/users/007/statuses/timeline", @params
      response.code.should == "404"
    end

    it "should return code 404 when not found" do
      @lecture = Factory(:lecture)
      get "/api/users/#{@lecture.id}/statuses/timeline", @params
      response.code.should == "404"
    end
  end

end
