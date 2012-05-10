require "net/http"

module Api
  class VisController < Api::ApiController
    # GET /api/vis/spaces/:space_id
    def lecture_participation
      @params = {
        'lectures[]' => params[:lectures],
        :date_start => params[:date_start],
        :date_end => params[:date_end]
      }

      debugger
      url = Redu::Application.config.vis[:lecture_participation]
      conn = Faraday.new(:url => url)

      resp = conn.get do |req|
        req.params = @params
      end

      respond_with resp
    end
  end
end
