# -*- encoding : utf-8 -*-
require "api_spec_helper"

describe "Statuses" do
  before do
    @application, @current_user, @token = generate_token
  end

  context "when listing User statuses" do
    let(:space) do
      environment = FactoryGirl.create(:complete_environment, owner: @current_user)
      environment.courses.first.spaces.first
    end
    let(:lecture) do
      s = FactoryGirl.create(:subject, owner: space.owner, space: space)
      FactoryGirl.create(:lecture, owner: s.owner, subject: s)
    end
    before do
      @user_statuses = [
        FactoryGirl.create(:help, user: @current_user, statusable: lecture),
        FactoryGirl.create(:activity, user: @current_user, statusable: lecture),
        FactoryGirl.create(:log, user: @current_user, statusable: space,
                logeable: lecture)
      ]

      # Um pouco de ruído
      FactoryGirl.create(:help, statusable: lecture)
      FactoryGirl.create(:log, statusable: space, logeable: lecture)
      FactoryGirl.create(:activity, statusable: lecture)
    end

    it "should return code 200" do
      get "/api/users/#{@current_user.id}/statuses", oauth_token: @token,
        format: 'json'
      response.code.should == "200"
    end

    it "should return correct numbers statuses" do
      get "/api/users/#{@current_user.id}/statuses", oauth_token: @token,
        format: 'json'

      activity_or_help = @user_statuses.select do |s|
        %w(Activity Help Log).include? s.type
      end
      parse(response.body).count.should == activity_or_help.length
    end

    it_should_behave_like "status filter" do
      let(:url) { "/api/users/#{@current_user.id}/statuses" }
      let(:token) { @token }
      let(:statuses) { @user_statuses }
    end
  end

  context "when listing user statuses" do
    it_should_behave_like "pagination" do
      let(:entities) do
        4.times.collect do
          FactoryGirl.create(:activity, user: @current_user, statusable: @current_user)
        end
      end
      let(:params) do
        ["/api/users/#{@current_user.id}/statuses",
         { oauth_token: @token, format: 'json' }]
      end
    end
  end

  context "when listing on Space" do
    let(:space) do
      environment = FactoryGirl.create(:complete_environment, owner: @current_user)
      environment.courses.first.spaces.first
    end
    let(:lecture) do
      s = FactoryGirl.create(:subject, owner: space.owner, space: space)
      FactoryGirl.create(:lecture, owner: s.owner, subject: s)
    end
    before do
      @space_statuses = [
        FactoryGirl.create(:activity, statusable: space, user: @current_user),
        FactoryGirl.create(:log, statusable: space, logeable: space,
                user: @current_user)
      ]

      # Um pouco de ruído
      FactoryGirl.create(:help, statusable: lecture, user: @current_user)
      FactoryGirl.create(:activity, statusable: lecture, user: @current_user)
    end

    it "should return code 200" do
      get "/api/spaces/#{space.id}/statuses", oauth_token: @token,
        format: 'json'
      response.code.should == "200"
    end

    it "should return correct numbers statuses" do
      get "/api/spaces/#{space.id}/statuses", oauth_token: @token,
        format: 'json'
        parse(response.body).count.should ==  @space_statuses.length
    end

    it_should_behave_like "status filter" do
      let(:url) { "/api/spaces/#{space.id}/statuses" }
      let(:token) { @token }
      let(:statuses) { @space_statuses }
    end
  end

  context "when listing on Lecture" do
    let(:space) do
      environment = FactoryGirl.create(:complete_environment, owner: @current_user)
      environment.courses.first.spaces.first
    end
    let(:lecture) do
      s = FactoryGirl.create(:subject, owner: space.owner, space: space)
      FactoryGirl.create(:lecture, owner: s.owner, subject: s)
    end

    before do
      @lecture_statuses = [
        FactoryGirl.create(:help, statusable: lecture, user: @current_user),
        FactoryGirl.create(:activity, statusable: lecture, user: @current_user),
      ]

      # Um pouco de ruído
      FactoryGirl.create(:help, statusable: FactoryGirl.create(:lecture), user: @current_user)
      FactoryGirl.create(:log, statusable: FactoryGirl.create(:lecture), logeable: lecture,
              user: @current_user)
      FactoryGirl.create(:activity, statusable: FactoryGirl.create(:lecture), user: @current_user)
    end

    it "should return code 200" do
      get "/api/lectures/#{lecture.id}/statuses", oauth_token: @token,
        format: 'json'
        response.code.should == "200"
    end

    it "should return correct numbers statuses" do
      get "/api/lectures/#{lecture.id}/statuses", oauth_token: @token,
        format: 'json'
      parse(response.body).count.should ==
        @lecture_statuses.select {|i| i[:type] == "Activity" or i[:type] == "Help" }.length
    end

    it_should_behave_like "status filter" do
      let(:url) { "/api/lectures/#{lecture.id}/statuses" }
      let(:token) { @token }
      let(:statuses) { @lecture_statuses }
    end
  end

  context "when creating a status on user" do
    let(:params) do
      { status: { text: 'Ximbica' }, oauth_token: @token,
        format: 'json' }
    end

    it "should return 201" do
      post "/api/users/#{@current_user.id}/statuses", params
      response.code.should == "201"
    end

    it "should create status with the correct statusable" do
      post "/api/users/#{@current_user.id}/statuses", params

      get href_to("statusable", parse(response.body)), oauth_token: @token,
        format: 'json'
      response.code.should == "200"
    end

    it "should return statusable user" do
      post "/api/users/#{@current_user.id}/statuses", params

      get href_to("statusable", parse(response.body)), oauth_token: @token,
        format: 'json'
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
          params.merge(format: 'html')
        response.code.should == "201"
        response.content_type.to_s.should == 'application/json'
      end
    end
  end

  context "when deleting status" do
    let(:space) do
      environment = FactoryGirl.create(:complete_environment, owner: @current_user)
      environment.courses.first.spaces.first
    end
    let(:lecture) do
      s = FactoryGirl.create(:subject, owner: space.owner, space: space)
      FactoryGirl.create(:lecture, owner: s.owner, subject: s)
    end
    let(:activity) do
      FactoryGirl.create(:activity, statusable: @current_user, user: @current_user)
    end
    let(:help) do
      FactoryGirl.create(:help, statusable: lecture, user: @current_user)
    end
    let(:log) do
      FactoryGirl.create(:log, statusable: space, user: @current_user,
              logeable: space)
    end
    let(:answer) do
      FactoryGirl.create(:answer, statusable: activity, in_response_to: activity,
              user: @current_user)
    end

    it "should return status 204 when activity type" do
      delete "/api/statuses/#{activity.id}", oauth_token: @token,
       format: 'json'

      response.status.should == 204
    end

    it "should return status 204 when help type" do
      delete "/api/statuses/#{help.id}", oauth_token: @token,
        format: 'json'

      response.status.should == 204
    end

    it "should return status 204 when answer type" do
      delete "/api/statuses/#{answer.id}", oauth_token: @token,
        format: 'json'

      response.status.should == 204
    end

    it "should return status 404 when not found" do
      delete "/api/statuses/#{activity.id}", oauth_token: @token,
        format: 'json'

      # Removido
      delete "/api/statuses/#{activity.id}", oauth_token: @token,
        format: 'json'
      response.status.should == 404
    end

    it "should return status 404 when does not exist" do
      delete "/api/statuses/007", oauth_token: @token, format: 'json'
      response.status.should == 404
    end
  end

  context "when creating status on space" do
    let(:space) do
      environment = FactoryGirl.create(:complete_environment, owner: @current_user)
      environment.courses.first.spaces.first
    end
    let(:params) do
      { status: { text: "Space Ximbica" },
        oauth_token: @token, format: "json" }
    end

    it "should return 201" do
      post "/api/spaces/#{space.id}/statuses", params
      response.code.should == "201"
    end

    it "should create status with the correct statusable" do
      post "/api/spaces/#{space.id}/statuses", params

      get href_to("statusable", parse(response.body)), oauth_token: @token,
        format: 'json'
      response.code.should == "200"
    end

    it "should return statusable space" do
      post "/api/spaces/#{space.id}/statuses", params

      get href_to("statusable", parse(response.body)), oauth_token: @token,
        format: 'json'
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
      environment = FactoryGirl.create(:complete_environment, owner: @current_user)
      environment.courses.first.spaces.first
    end
    let(:lecture) do
      s = FactoryGirl.create(:subject, owner: space.owner, space: space)
      c = FactoryGirl.create(:canvas, user: s.owner)
      FactoryGirl.create(:lecture, owner: s.owner, subject: s,
              lectureable: c)
    end
    let(:params) do
      { status: { text: "Lacture Ximbica" }, oauth_token: @token,
        format: 'json' }
    end

    it "should return 201" do
      params[:status][:type] = "Activity"
      post "/api/lectures/#{lecture.id}/statuses", params
      response.code.should == "201"
    end

    it "should return correct statusable lecture" do
      params[:status][:type] = "Activity"
      post "/api/lectures/#{lecture.id}/statuses", params

      get href_to("statusable", parse(response.body)), oauth_token: @token,
        format: 'json'

      parse(response.body)["name"].should == lecture.name
    end

    it "should create an activity" do
      params[:status][:type] = "Activity"
      post "/api/lectures/#{lecture.id}/statuses", params

      parse(response.body)["type"].should == "Activity"
    end

    it "should return correct statusable" do
      params[:status][:type] = "activity"
      post "/api/lectures/#{lecture.id}/statuses", params

      get href_to("statusable", parse(response.body)), oauth_token: @token,
        format: 'json'
      parse(response.body)["name"].should == lecture.name
    end

    it "should create an activity when there is not type" do
      post "/api/lectures/#{lecture.id}/statuses", params

      parse(response.body)["type"].should == "Activity"
    end
  end

  context "when creating status (type Help) on Lecture" do
    let(:space) do
      environment = FactoryGirl.create(:complete_environment, owner: @current_user)
      environment.courses.first.spaces.first
    end
    let(:lecture) do
      s = FactoryGirl.create(:subject, owner: space.owner, space: space)
      c = FactoryGirl.create(:canvas, user: s.owner)
      FactoryGirl.create(:lecture, owner: s.owner, subject: s,
              lectureable: c)
    end
    let(:params) do
      { status: { text: "Lacture Ximbica", type: 'Help' },
        oauth_token: @token,
        format: 'json' }
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

      get href_to("statusable", parse(response.body)), oauth_token: @token,
        format: 'json'
      response.code.should == "200"
    end

    it "should return 422 when invalid" do
      params[:status][:text] = ""
      post "/api/lectures/#{lecture.id}/statuses", params

      response.code.should == "422"
    end
  end

  context "when trying to create a status with unwanted type" do
    let(:params) do
      {"status" => {text: "Ximbica Answer Test", type: 'User' },
       oauth_token: @token, format: 'json' }
    end
    let(:space) do
      environment = FactoryGirl.create(:complete_environment, owner: @current_user)
      environment.courses.first.spaces.first
    end

    it "should not be valid" do
      post "/api/spaces/#{space.id}/statuses", params
      response.code.should == '400'
    end
  end

  context "when listing overview on Space" do
    let(:space) do
      environment = FactoryGirl.create(:complete_environment, owner: @current_user)
      environment.courses.first.spaces.first
    end

    let(:params) do
      { oauth_token: @token, format: 'json' }
    end

    it "should return code 200" do
      get "/api/spaces/#{space.id}/statuses/timeline", params
      response.code.should == "200"
    end

    it "should return text of status created on space" do
      create_params = params.merge({status: { text: "Ximbica over" }})

      post "/api/spaces/#{space.id}/statuses", create_params
      get "/api/spaces/#{space.id}/statuses/timeline", params

      parse(response.body)[0]['text'].should == "Ximbica over"
    end

    it "should not return empty body" do
      create_params = params.merge({status: { text: "Ximbica over" }})

      post "/api/spaces/#{space.id}/statuses", create_params
      get "/api/spaces/#{space.id}/statuses/timeline", params

      parse(response.body).should_not be_empty
    end
  end

  context "when listing overview on Space" do
    let(:environment) do
      FactoryGirl.create(:complete_environment, owner: @current_user)
    end
    let(:space) { environment.courses.first.spaces.first }

    before do
      4.times do
        FactoryGirl.create(:activity, statusable: space, user: @current_user)
      end
    end

    it_should_behave_like "pagination" do
      let(:params) do
        [ "/api/spaces/#{space.id}/statuses/timeline",
          { oauth_token: @token, format: 'json' }]
      end
      let(:entities) { space.statuses }
    end

  end

  context "when listing User overview" do
    let(:environment) do
      FactoryGirl.create(:complete_environment, owner: @current_user)
    end
    let(:space) { environment.courses.first.spaces.first }
    before do
      ActiveRecord::Observer.with_observers(:status_observer) do
        params = { oauth_token: @token, format: 'json' }
        create_params = params.merge({ status: { text: "text" } })

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
         { oauth_token: @token, format: 'json' }]
      end
    end

  end
  context "when listing User overview" do
    let(:params) do
      { oauth_token: @token, format: 'json' }
    end
    let(:space) do
      environment = FactoryGirl.create(:complete_environment, owner: @current_user)
      environment.courses.first.spaces.first
    end
    let(:lecture) do
      s = FactoryGirl.create(:subject, owner: space.owner, space: space)
      FactoryGirl.create(:lecture, owner: s.owner, subject: s)
    end

    before do
      # Associação do user com uma atividade
      ActiveRecord::Observer.with_observers(:status_observer) do
        create_params = params.merge({ status: { text: "text" } })

        post "/api/users/#{@current_user.id}/statuses", create_params
        @activity = parse(response.body)

        @user_statuses = [
        FactoryGirl.create(:help, user: @current_user, statusable: lecture),
        FactoryGirl.create(:activity, user: @current_user, statusable: lecture),
        FactoryGirl.create(:log, user: @current_user, statusable: space,
                logeable: lecture)
      ]
      end
    end

    it "should return 200" do
      get "/api/users/#{@current_user.id}/statuses/timeline", params
      response.code.should == "200"
    end

    it "should return id of status" do
      get "/api/users/#{@current_user.id}/statuses/timeline", params
      parse(response.body).any? {|s| s['id'] == @activity['id']}.should be
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
      @lecture = FactoryGirl.create(:lecture)
      get "/api/users/212/statuses/timeline", params
      response.code.should == "404"
    end

    %w(Help help Activity activity Log log).each do |filter|
      it "should filter by #{filter}" do
        get "/api/users/#{@current_user.id}/statuses/timeline", type: filter,
          oauth_token: @token, format: 'json'
        parse(response.body).all? {|s| s["type"] == filter.classify}.should be
      end

      it "should return correct number of statuses #{filter}" do
        get "/api/users/#{@current_user.id}/statuses/timeline", type: filter,
        oauth_token: @token, format: 'json'
        stats = @current_user.overview.where(type: filter.classify)
        parse(response.body).count.should == stats.count
      end
    end
  end

  context "when invalid status" do
    let(:params) { { oauth_token: @token, format: 'json' } }

    it "should not allow using help instead of activity" do
      help = { status: { type: 'Help', text: 'Lorem' } }
      post "/api/users/#{@current_user.id}/statuses", params.merge(help)

      response.code.should == "422"
    end

    %w(Help Activity Log Status).each do |type|
      it "should not allow answering an activity with a #{type}" do
        activity = { status: { text: 'Lorem' } }
        post "/api/users/#{@current_user.id}/statuses", params.merge(activity)

        url = href_to('answers', parse(response.body))
        activity[:status][:type] = type

        post url, params.merge(activity)
        parse(response.body)['type'].should == 'Answer'
      end
    end

    it "should not allow creating anything with status type" do
      activity = { status: { text: 'Lorem' } }
      post "/api/users/#{@current_user.id}/statuses", params.merge(activity)

      parse(response.body)['type'].should == 'Activity'
    end

    it "should not allow creating a status with log type" do
      activity = { status: { text: 'Lorem', type: 'Log' } }
      post "/api/users/#{@current_user.id}/statuses", params.merge(activity)

      response.code.should == "422"
    end
  end

  context "when there are Compound Logs" do
    let(:compound) { FactoryGirl.create(:compound_log, user: @current_user) }
    let(:params) { { oauth_token: @token, format: 'json' } }
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
      status = { status: { text: 'Answer' } }
      post "/api/statuses/#{compound.id}/answers", params.merge!(status)
      response.code.should == "401"
    end
  end
end
