require "api_spec_helper"

describe "Statuses" do
  before do
    @application, @current_user, @token = generate_token
  end

  context "when Activity type" do
    let(:activity) do
      Factory(:activity, :user => @current_user, :statusable => @current_user)
    end
    before do
      get "/api/statuses/#{activity.id}", :oauth_token => @token, :format => 'json'
      @entity = parse(response.body)
    end

    it "should return status 200 (ok)" do
      response.code.should == '200'
    end

    it "should have id, text, created_at, links and type" do
      %w(id text created_at links updated_at type).each do |attr|
        @entity.should have_key attr
      end
    end

    it "should have a link to its Answers" do
      get href_to('answers', @entity), :oauth_token => @token, :format => 'json'
      response.code.should == "200"
    end

    it "should have the correct links (statusable, user, self)" do
      %w(statusable self user).each do |attr|
        get href_to(attr, @entity), :oauth_token => @token, :format => 'json'
        response.code.should == "200"
      end
    end

    it_should_behave_like "embeds user" do
      let(:embeder) { activity }
      let(:user) { embeder.user }
      let(:entity) { @entity }
    end
  end

  context "when Answer type" do
    let(:activity) do
      Factory(:activity, :user => @current_user, :statusable => @current_user)
    end
    let(:answer) do
      Factory(:answer, :statusable => @current_user,
              :user => @current_user, :in_response_to => activity)
    end
    before do
      get "/api/statuses/#{answer.id}", :oauth_token => @token, :format => 'json'
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

    it_should_behave_like "embeds user" do
      let(:embeder) { answer }
      let(:user) { embeder.user }
      let(:entity) { @entity }
    end
  end

  context "when Log type" do
    let(:space) do
      environment = Factory(:complete_environment, :owner => @current_user)
      environment.courses.first.spaces.first
    end
    let(:log) do
      Factory(:log, :statusable => space, :user => @current_user,
              :logeable => space)
    end

    before do
      get "/api/statuses/#{log.id}", :oauth_token => @token, :format => 'json'
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

    it "should have the correct link to statusable, self, user and logeable" do
      %w(statusable self user logeable).each do |attr|
        get href_to(attr, @entity), :oauth_token => @token, :format => 'json'
        response.code.should == "200"
      end
    end

    it_should_behave_like "embeds user" do
      let(:embeder) { log }
      let(:user) { embeder.user }
      let(:entity) { @entity }
    end
  end

  context "when Help type" do
    let(:space) do
      environment = Factory(:complete_environment, :owner => @current_user)
      environment.courses.first.spaces.first
    end
    let(:lecture) do
      s = Factory(:subject, :owner => space.owner, :space => space)
      Factory(:lecture, :owner => s.owner, :subject => s)
    end
    let(:help) do
      Factory(:help, :user => lecture.owner, :statusable => lecture)
    end
    before do
      get "/api/statuses/#{help.id}", :oauth_token => @token, :format => 'json'
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

    it_should_behave_like "embeds user" do
      let(:embeder) { help }
      let(:user) { embeder.user }
      let(:entity) { @entity }
    end
  end

  context "when listing User statuses" do
    let(:space) do
      environment = Factory(:complete_environment, :owner => @current_user)
      environment.courses.first.spaces.first
    end
    let(:lecture) do
      s = Factory(:subject, :owner => space.owner, :space => space)
      Factory(:lecture, :owner => s.owner, :subject => s)
    end
    before do
      @user_statuses = [
        Factory(:help, :user => @current_user, :statusable => lecture),
        Factory(:activity, :user => @current_user, :statusable => lecture),
        Factory(:log, :user => @current_user, :statusable => space,
                :logeable => lecture)
      ]

      # Um pouco de ruído
      Factory(:help, :statusable => lecture)
      Factory(:log, :statusable => space, :logeable => lecture)
      Factory(:activity, :statusable => lecture)
    end

    it "should return code 200" do
      get "/api/users/#{@current_user.id}/statuses", :oauth_token => @token,
        :format => 'json'
      response.code.should == "200"
    end

    it "should return correct numbers statuses" do
      get "/api/users/#{@current_user.id}/statuses", :oauth_token => @token,
        :format => 'json'

      activity_or_help = @user_statuses.select do |s|
        %w(Activity Help).include? s.type
      end
      parse(response.body).count.should == activity_or_help.length
    end

    %w(Help help Log log  Activity activity).each do |filter|
      it "should filter by statatus type #{filter}" do
        get "/api/users/#{@current_user.id}/statuses", :type => filter,
        :oauth_token => @token, :format => 'json'
        parse(response.body).all? { |s| s["type"] == filter.classify }.should be
      end

      it "should return correct number of statuses #{filter}" do
        get "/api/users/#{@current_user.id}/statuses", :type => filter,
        :oauth_token => @token, :format => 'json'
        stats = @user_statuses.select {|i| i[:type] == filter.classify}
        parse(response.body).count.should == stats.length
      end
    end

  end

  context "when listing user statuses" do
    it_should_behave_like "pagination" do
      let(:entities) do
        4.times.collect do
          Factory(:activity, :user => @current_user, :statusable => @current_user)
        end
      end
      let(:params) do
        ["/api/users/#{@current_user.id}/statuses",
         { :oauth_token => @token, :format => 'json' }]
      end
    end
  end

  context "when listing on Space" do
    let(:space) do
      environment = Factory(:complete_environment, :owner => @current_user)
      environment.courses.first.spaces.first
    end
    let(:lecture) do
      s = Factory(:subject, :owner => space.owner, :space => space)
      Factory(:lecture, :owner => s.owner, :subject => s)
    end
    before do
      @space_statuses = [
        Factory(:activity, :statusable => space, :user => @current_user),
        Factory(:log, :statusable => space, :logeable => space,
                :user => @current_user)
      ]

      # Um pouco de ruído
      Factory(:help, :statusable => lecture, :user => @current_user)
      Factory(:log, :statusable => space, :logeable => lecture,
              :user => @current_user)
      Factory(:activity, :statusable => lecture, :user => @current_user)
    end

    it "should return code 200" do
      get "/api/spaces/#{space.id}/statuses", :oauth_token => @token,
        :format => 'json'
      response.code.should == "200"
    end

    it "should return correct numbers statuses" do
      get "/api/spaces/#{space.id}/statuses", :oauth_token => @token,
        :format => 'json'
        activities = @space_statuses.select { |i| i[:type] == "Activity" }

        parse(response.body).count.should ==  activities.length
    end

    it "should filter by status type (help)" do
      get "/api/spaces/#{space.id}/statuses", :type => 'help',
        :oauth_token => @token, :format => 'json'

      parse(response.body).all? { |s| s["type"] == "Help" }.should be
    end

    it "should filter by status type (log)" do
      get "/api/spaces/#{space.id}/statuses", :type => 'log',
        :oauth_token => @token, :format => 'json'

      parse(response.body).all? { |s| s["type"] == "Log" }.should be
    end

    it "should filter by status type (activity)" do
      get "/api/spaces/#{space.id}/statuses", :type => 'activity',
        :oauth_token => @token, :format => 'json'
      parse(response.body).all? { |s| s["type"] == "Activity" }.should be
    end
  end

  context "when listing on Lecture" do
    let(:space) do
      environment = Factory(:complete_environment, :owner => @current_user)
      environment.courses.first.spaces.first
    end
    let(:lecture) do
      s = Factory(:subject, :owner => space.owner, :space => space)
      Factory(:lecture, :owner => s.owner, :subject => s)
    end

    before do
      @lecture_statuses = [
        Factory(:help, :statusable => lecture, :user => @current_user),
        Factory(:activity, :statusable => lecture, :user => @current_user),
      ]

      # Um pouco de ruído
      Factory(:help, :statusable => Factory(:lecture), :user => @current_user)
      Factory(:log, :statusable => Factory(:lecture), :logeable => lecture,
              :user => @current_user)
      Factory(:activity, :statusable => Factory(:lecture), :user => @current_user)
    end

    it "should return code 200" do
      get "/api/lectures/#{lecture.id}/statuses", :oauth_token => @token,
        :format => 'json'
        response.code.should == "200"
    end

    it "should return correct numbers statuses" do
      get "/api/lectures/#{lecture.id}/statuses", :oauth_token => @token,
        :format => 'json'
      parse(response.body).count.should ==
        @lecture_statuses.select {|i| i[:type] == "Activity" or i[:type] == "Help" }.length
    end

    it "should filter by status type (help)" do
      get "/api/lectures/#{lecture.id}/statuses", :type => 'help' ,
        :oauth_token => @token, :format => 'json'
      parse(response.body).all? { |s| s["type"] == "Help" }.should be
    end

    it "should filter by status type (log)" do
      get "/api/lectures/#{lecture.id}/statuses", :type => 'log' ,
        :oauth_token => @token, :format => 'json'
      parse(response.body).all? { |s| s["type"] == "Log" }.should be
    end

    it "should filter by status type (activity)" do
      get "/api/lectures/#{lecture.id}/statuses", :type => 'activity',
        :oauth_token => @token, :format => 'json'

      parse(response.body).all? { |s| s["type"] == "Activity" }.should be
    end
  end

  context "when creating a status on user" do
    let(:params) do
      { :status => { :text => 'Ximbica' }, :oauth_token => @token,
        :format => 'json' }
    end

    it "should return 201" do
      post "/api/users/#{@current_user.id}/statuses", params
      response.code.should == "201"
    end

    it "should create status with the correct statusable" do
      post "/api/users/#{@current_user.id}/statuses", params

      get href_to("statusable", parse(response.body)), :oauth_token => @token,
        :format => 'json'
      response.code.should == "200"
    end

    it "should return statusable user" do
      post "/api/users/#{@current_user.id}/statuses", params

      get href_to("statusable", parse(response.body)), :oauth_token => @token,
        :format => 'json'
      parse(response.body)["first_name"].should == @current_user.first_name
    end

    it "should create an activity" do
      post "/api/users/#{@current_user.id}/statuses", params

      parse(response.body)["type"].should == "Activity"
    end

    it "should return 422 when invalid" do
      params[:status][:text] = ""
      post "/api/users/#{@current_user.id}/statuses", params

      response.code.should == "422"
    end

    context "when using an invalid Accept header (html)" do
      it "should create the status and return it as json" do
        post "/api/users/#{@current_user.id}/statuses",
          params.merge(:format => 'html')
        response.code.should == "201"
        response.content_type.to_s.should == 'application/json'
      end
    end
  end

  context "when deleting status" do
    let(:space) do
      environment = Factory(:complete_environment, :owner => @current_user)
      environment.courses.first.spaces.first
    end
    let(:lecture) do
      s = Factory(:subject, :owner => space.owner, :space => space)
      Factory(:lecture, :owner => s.owner, :subject => s)
    end
    let(:activity) do
      Factory(:activity, :statusable => @current_user, :user => @current_user)
    end
    let(:help) do
      Factory(:help, :statusable => lecture, :user => @current_user)
    end
    let(:log) do
      Factory(:log, :statusable => space, :user => @current_user,
              :logeable => space)
    end
    let(:answer) do
      Factory(:answer, :statusable => activity, :in_response_to => activity,
              :user => @current_user)
    end

    it "should return status 200 when activity type" do
      delete "/api/statuses/#{activity.id}", :oauth_token => @token,
       :format => 'json'

      response.status.should == 200
    end

    it "should return status 200 when help type" do
      delete "/api/statuses/#{help.id}", :oauth_token => @token,
        :format => 'json'

      response.status.should == 200
    end

    it "should return status 200 when log type" do
      get "/api/statuses/#{log.id}", :oauth_token => @token,
        :format => 'json'

      response.status.should == 200
    end

    it "should return status 200 when answer type" do
      delete "/api/statuses/#{answer.id}", :oauth_token => @token,
        :format => 'json'

      response.status.should == 200
    end

    it "should return status 404 when not found" do
      delete "/api/statuses/#{activity.id}", :oauth_token => @token,
        :format => 'json'

      # Removido
      delete "/api/statuses/#{activity.id}", :oauth_token => @token,
        :format => 'json'
      response.status.should == 404
    end

    it "should return status 404 when does not exist" do
      delete "/api/statuses/007", :oauth_token => @token, :format => 'json'
      response.status.should == 404
    end
  end

  context "when creating status on space" do
    let(:space) do
      environment = Factory(:complete_environment, :owner => @current_user)
      environment.courses.first.spaces.first
    end
    let(:params) do
      { :status => { :text => "Space Ximbica" },
        :oauth_token => @token, :format => "json" }
    end

    it "should return 201" do
      post "/api/spaces/#{space.id}/statuses", params
      response.code.should == "201"
    end

    it "should create status with the correct statusable" do
      post "/api/spaces/#{space.id}/statuses", params

      get href_to("statusable", parse(response.body)), :oauth_token => @token,
        :format => 'json'
      response.code.should == "200"
    end

    it "should return statusable space" do
      post "/api/spaces/#{space.id}/statuses", params

      get href_to("statusable", parse(response.body)), :oauth_token => @token,
        :format => 'json'
      parse(response.body)['name'].should == space.name
    end

    it "should create an activity" do
      post "/api/spaces/#{space.id}/statuses", params

      parse(response.body)["type"].should == "Activity"
    end

    it "should return 422 when invalid" do
      params[:status][:text] = ""
      post "/api/spaces/#{space.id}/statuses", params

      response.code.should == "422"
    end

    it "should return 422 when invalid statusable_type" do
      params[:status][:type] = "Help"
      post "/api/spaces/#{space.id}/statuses", params

      response.code.should == "422"
    end
  end

  context "when creating status (type Activity) on Lecture" do
    let(:space) do
      environment = Factory(:complete_environment, :owner => @current_user)
      environment.courses.first.spaces.first
    end
    let(:lecture) do
      s = Factory(:subject, :owner => space.owner, :space => space)
      Factory(:lecture, :owner => s.owner, :subject => s)
    end
    let(:params) do
      { :status => { :text => "Lacture Ximbica" }, :oauth_token => @token,
        :format => 'json' }
    end

    it "should return 201" do
      params[:status][:type] = "Activity"
      post "/api/lectures/#{lecture.id}/statuses", params
      response.code.should == "201"
    end

    it "should return correct statusable lecture" do
      params[:status][:type] = "Activity"
      post "/api/lectures/#{lecture.id}/statuses", params

      get href_to("statusable", parse(response.body)), :oauth_token => @token,
        :format => 'json'

      parse(response.body)["lecture"]["name"].should == lecture.name
    end

    it "should create an activity" do
      params[:status][:type] = "Activity"
      post "/api/lectures/#{lecture.id}/statuses", params

      parse(response.body)["type"].should == "Activity"
    end

    it "should return correct statusable" do
      params[:status][:type] = "activity"
      post "/api/lectures/#{lecture.id}/statuses", params

      get href_to("statusable", parse(response.body)), :oauth_token => @token,
        :format => 'json'
      parse(response.body)["lecture"]["name"].should == lecture.name
    end

    it "should create an activity when there is not type" do
      post "/api/lectures/#{lecture.id}/statuses", params

      parse(response.body)["type"].should == "Activity"
    end
  end

  context "when creating status (type Help) on Lecture" do
    let(:space) do
      environment = Factory(:complete_environment, :owner => @current_user)
      environment.courses.first.spaces.first
    end
    let(:lecture) do
      s = Factory(:subject, :owner => space.owner, :space => space)
      Factory(:lecture, :owner => s.owner, :subject => s)
    end
    let(:params) do
      { :status => { :text => "Lacture Ximbica", :type => 'Help' },
        :oauth_token => @token,
        :format => 'json' }
    end

    it "should create a status with the lecture type help and return 201" do
      post "/api/lectures/#{lecture.id}/statuses", params

      response.code.should == "201"
    end

    it "should create an help" do
      post "/api/lectures/#{lecture.id}/statuses", params

      parse(response.body)["type"].should == "Help"
    end

    it "should return statusable" do
      post "/api/lectures/#{lecture.id}/statuses", params

      get href_to("statusable", parse(response.body)), :oauth_token => @token,
        :format => 'json'
      response.code.should == "200"
    end

    it "should return 422 when invalid" do
      params[:status][:text] = ""
      post "/api/lectures/#{lecture.id}/statuses", params

      response.code.should == "422"
    end
  end

  context "when creating an Answer" do
    let(:space) do
      environment = Factory(:complete_environment, :owner => @current_user)
      environment.courses.first.spaces.first
    end
    let(:lecture) do
      s = Factory(:subject, :owner => space.owner, :space => space)
      Factory(:lecture, :owner => s.owner, :subject => s)
    end
    let(:activity) do
      Factory(:activity, :user => @current_user, :statusable => @current_user)
    end
    let(:help) do
      Factory(:help, :user => @current_user, :statusable => lecture)
    end
    let(:params) do
      { :status => {:text => "Ximbica Answer Test" },
        :oauth_token => @token, :format => 'json' }
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
      @log = Factory(:log) # tipo inválido
      post "/api/statuses/#{@log.id}/answers", @params
      # Deve ser atualizado com authorize
      response.code.should == "422"
    end

    it "should return correct statusable" do
      post "/api/statuses/#{activity.id}/answers", params

      get href_to("statusable", parse(response.body)), :oauth_token => @token,
        :format => 'json'
      response.code.should == "200"
    end

    it "should return corret in_response_to" do
      post "/api/statuses/#{activity.id}/answers", params

      get href_to("in_response_to", parse(response.body)), :oauth_token => @token,
        :format => 'json'
      response.code.should == "200"
    end

    it "should return correct in_response_to type (Activity)" do
      post "/api/statuses/#{activity.id}/answers", params

      get href_to("in_response_to", parse(response.body)), :oauth_token => @token,
        :format => 'json'
      parse(response.body)["type"].should == "Activity"
    end

    it "should return correct in_response_to type (Help)" do
      post "/api/statuses/#{help.id}/answers", params

      get href_to("in_response_to", parse(response.body)), :oauth_token => @token,
        :format => 'json'
      parse(response.body)["type"].should == "Help"
    end
  end

  context "when listing Answers" do
    let(:activity) do
      Factory(:activity, :statusable => @current_user, :user => @current_user)
    end
    let(:params) do
      { :status => {:text => "Ximbica Answer Test" },
        :oauth_token => @token, :format => 'json' }
    end
    before do
      2.times do
        post "/api/statuses/#{activity.id}/answers", params
      end
    end

    it "should return code 200" do
      get "/api/statuses/#{activity.id}/answers", :oauth_token => @token,
        :format => 'json'
      response.code.should == "200"
    end
  end

  context "when trying to create a status with unwanted type" do
    let(:params) do
      {"status" => {:text => "Ximbica Answer Test", :type => 'User' },
       :oauth_token => @token, :format => 'json' }
    end
    let(:space) do
      environment = Factory(:complete_environment, :owner => @current_user)
      environment.courses.first.spaces.first
    end

    it "should not be valid" do
      post "/api/spaces/#{space.id}/statuses", params
      response.code.should == '400'
    end
  end

  context "when listing overview on Space" do
    let(:space) do
      environment = Factory(:complete_environment, :owner => @current_user)
      environment.courses.first.spaces.first
    end

    let(:params) do
      { :oauth_token => @token, :format => 'json' }
    end

    it "should return code 200" do
      get "/api/spaces/#{space.id}/statuses/timeline", params
      response.code.should == "200"
    end

    it "should return text of status created on space" do
      create_params = params.merge({:status => { :text => "Ximbica over" }})

      post "/api/spaces/#{space.id}/statuses", create_params
      get "/api/spaces/#{space.id}/statuses/timeline", params

      parse(response.body)[0]['text'].should == "Ximbica over"
    end

    it "should not return empty body" do
      create_params = params.merge({:status => { :text => "Ximbica over" }})

      post "/api/spaces/#{space.id}/statuses", create_params
      get "/api/spaces/#{space.id}/statuses/timeline", params

      parse(response.body).should_not be_empty
    end
  end

  context "when listing overview on Space" do
    let(:environment) do
      Factory(:complete_environment, :owner => @current_user)
    end
    let(:space) { environment.courses.first.spaces.first }

    before do
      4.times do
        Factory(:activity, :statusable => space, :user => @current_user)
      end
    end

    it_should_behave_like "pagination" do
      let(:params) do
        [ "/api/spaces/#{space.id}/statuses/timeline",
          { :oauth_token => @token, :format => 'json' }]
      end
      let(:entities) { space.statuses }
    end

  end

  context "when listing User overview" do
    let(:environment) do
      Factory(:complete_environment, :owner => @current_user)
    end
    let(:space) { environment.courses.first.spaces.first }
    before do
      ActiveRecord::Observer.with_observers(:status_observer) do
        params = { :oauth_token => @token, :format => 'json' }
        create_params = params.merge({ :status => { :text => "text" } })

        # Postando no próprio mural
        2.times do
          post "/api/users/#{@current_user.id}/statuses", create_params
        end

        # Postando na disciplina
        2.times do
          post "/api/spaces/#{space.id}/statuses", create_params
        end
      end
    end

    it_should_behave_like "pagination" do
      let(:entities) { @current_user.overview }
      let(:params) do
        ["/api/users/#{@current_user.id}/statuses/timeline",
         { :oauth_token => @token, :format => 'json' }]
      end
    end

  end
  context "when listing User overview" do
    let(:params) do
      { :oauth_token => @token, :format => 'json' }
    end
    before do
      # Associação do user com uma atividade
      ActiveRecord::Observer.with_observers(:status_observer) do
        create_params = params.merge({ :status => { :text => "text" } })

        post "/api/users/#{@current_user.id}/statuses", create_params
        @activity = parse(response.body)
      end
    end

    it "should return 200" do
      get "/api/users/#{@current_user.id}/statuses/timeline", params
      response.code.should == "200"
    end

    it "should return id of status" do
      get "/api/users/#{@current_user.id}/statuses/timeline", params
      parse(response.body)[0]['id'].should == @activity['id']
    end

    it "should not return empty body" do
      get "/api/users/#{@current_user.id}/statuses/timeline", params
      parse(response.body).should_not be_empty
    end

    it "should return the correct number of statuses" do
      get "/api/users/#{@current_user.id}/statuses/timeline", params

      parse(response.body).count.should == @current_user.overview.count
    end

    it "should return code 404 doesnt exist" do
      get "/api/users/007/statuses/timeline", params
      response.code.should == "404"
    end

    it "should return code 404 when not found" do
      @lecture = Factory(:lecture)
      get "/api/users/212/statuses/timeline", params
      response.code.should == "404"
    end
  end

  context "when invalid status" do
    let(:params) { { :oauth_token => @token, :format => 'json' } }

    it "should not allow using help instead of activity" do
      help = { :status => { :type => 'Help', :text => 'Lorem' } }
      post "/api/users/#{@current_user.id}/statuses", params.merge(help)

      response.code.should == "422"
    end

    %w(Help Activity Log Status).each do |type|
      it "should not allow answering an activity with a #{type}" do
        activity = { :status => { :text => 'Lorem' } }
        post "/api/users/#{@current_user.id}/statuses", params.merge(activity)

        url = href_to('answers', parse(response.body))
        activity[:status][:type] = type

        post url, params.merge(activity)
        parse(response.body)['type'].should == 'Answer'
      end
    end

    it "should not allow creating anything with status type" do
      activity = { :status => { :text => 'Lorem' } }
      post "/api/users/#{@current_user.id}/statuses", params.merge(activity)

      parse(response.body)['type'].should == 'Activity'
    end

    it "should not allow creating a status with log type" do
      activity = { :status => { :text => 'Lorem', :type => 'Log' } }
      post "/api/users/#{@current_user.id}/statuses", params.merge(activity)

      response.code.should == "422"
    end
  end

  context "when there are Compound Logs" do
    let(:compound) { Factory(:compound_log, :user => @current_user) }
    let(:params) { { :oauth_token => @token, :format => 'json' } }
    before do
      compound.statusable = @current_user
      compound.save
      Status.associate_with(compound, [@current_user])
    end

    it "should not be showed on timeline" do
      get "/api/users/#{@current_user.id}/statuses/timeline", params
      parse(response.body).should be_empty
    end

    it "should not be showed" do
      get "/api/statuses/#{compound.id}", params
      response.code.should == "401"
    end

    it "should not be indexed" do
      get "/api/users/#{@current_user.id}/statuses", params
      parse(response.body).should be_empty
    end

    it "should not be answered" do
      status = { :status => { :text => 'Answer' } }
      post "/api/statuses/#{compound.id}/answers", params.merge!(status)
      response.code.should == "401"
    end
  end

end
