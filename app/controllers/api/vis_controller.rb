require "net/http"

module Api
  class VisController < Api::ApiController
    # GET /api/vis/spaces/:space_id
    def lecture_participation
      @space = Space.find(params[:space_id])
      authorize! :manage, @space

      @params = { 'lectures[]' => params[:lectures],
                  :date_start => params[:date_start],
                  :date_end => params[:date_end] }
      @url = Redu::Application.config.vis[:lecture_participation]

      create_connection_and_response(@url, @params)
    end

    # GET /api/vis/subjects/:subject_id
    def subject_activities
      @subject = Subject.find(params[:subject_id])
      authorize! :manage, @subject

      @params = { :subject_id => @subject.id }
      @url = Redu::Application.config.vis[:activities]

      create_connection_and_response(@url, @params)
    end

    def subject_activities_d3
      @subject = Subject.find(params[:subject_id])
      authorize! :manage, @subject

      @params = { :subject_id => @subject.id }
      @url = Redu::Application.config.vis[:activities_d3]

      create_connection_and_response(@url, @params)
    end

    protected

    def create_connection_and_response(url, param)
      conn = Faraday.new(:url => url,
                         :headers => {'Authorization' =>
                          Base64::encode64("api-team:NyugAkSoP"),
                                      'Content-Type' => 'application/json' },
                         :params => param)

      resp = conn.get

      respond_to do |format|
        format.json { render :json => resp.body, :status => resp.status }
      end
    end
  end
end
