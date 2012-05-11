require "net/http"

module Api
  class VisController < Api::ApiController
    # GET /api/vis/spaces/:space_id
    def lecture_participation
      @space = Space.find(params[:space_id])
      authorize! :manage, @space

      @params = {
        'lectures[]' => params[:lectures],
        :date_start => params[:date_start],
        :date_end => params[:date_end]
      }

      url = Redu::Application.config.vis[:lecture_participation]
      conn = Faraday.new(:url => url)

      resp = conn.get do |req|
        req.params = @params
      end

      respond_to do |format|
        format.json { render :json => resp.body }
      end
    end

    # GET /api/vis/subjects/:subject_id
    def subject_activities
      @subject = Subject.find(params[:subject_id])
      authorize! :manage, @subject

      @params = {
        :subject_id => @subject.id
      }

      url = Redu::Application.config.vis[:activities]
      conn = Faraday.new(:url => url)

      resp = conn.get do |req|
        req.params = @params
      end

      respond_to do |format|
        format.json { render :json => resp.body }
      end
    end

    # GET /api/vis/subjects/:subject_id
    def subject_activities_d3
      @subject = Subject.find(params[:subject_id])
      authorize! :manage, @subject

      @params = {
        :subject_id => @subject.id
      }

      url = Redu::Application.config.vis[:activities_d3]
      conn = Faraday.new(:url => url)

      resp = conn.get do |req|
        req.params = @params
      end

      respond_to do |format|
        format.json { render :json => resp.body }
      end
    end
  end
end
