require "net/http"

module Api
  class VisController < Api::ApiController

    # GET /api/vis/spaces/:space_id
    def students_participation
      space = Space.find(params[:space_id])
      authorize! :manage, space

      param = { 'users_id[]' => params[:users_id],
                :date_start => params[:date_start],
                :date_end => params[:date_end],
                :space_id => params[:space_id] }
      url = Redu::Application.config.vis[:students_participation]

      request_resp = request_vis(url, param)
      create_response(request_resp)
    end

    # GET /api/vis/spaces/:space_id
    def lecture_participation
      space = Space.find(params[:space_id])
      authorize! :manage, space

      param = { 'lectures[]' => params[:lectures],
                :date_start => params[:date_start],
                :date_end => params[:date_end] }
      url = Redu::Application.config.vis[:lecture_participation]

      request_resp = request_vis(url, param)
      create_response(request_resp)
    end

    # GET /api/vis/spaces/:space_id
    def subject_activities
      space = Space.find(params[:space_id])
      authorize! :manage, space

      param = { 'subjects[]' => params[:subjects] }
      url = Redu::Application.config.vis[:subject_activities]

      request_resp = request_vis(url, param)
      create_response(request_resp)
    end

    protected

    def request_vis(url, param)
      password = Redu::Application.config.vis_data_authentication[:password]
      username = Redu::Application.config.vis_data_authentication[:username]
      conn = Faraday.new(
        :url => url,
        :headers => {'Authorization' =>
                     Base64::encode64("#{username}:#{password}"),
                     'Content-Type' => 'application/json' },
        :params => param)

      resp = conn.get
    end

    def create_response(resp)
      respond_to do |format|
        format.json { render :json => resp.body, :status => resp.status,
                      :callback => params[:callback] }
      end
    end
  end
end
