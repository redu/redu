module Api
  class AssetReportsController < Api::ApiController
    def show
      asset_report = AssetReport.find(params[:id])
      respond_with asset_report
    end

    def update
      asset_report = AssetReport.find(params[:id])
      asset_report.done = params[:progress][:finalized].to_s
      asset_report.save
      respond_with asset_report
    end

    # GET /api/lectures/:lecture_id/progress?user_id[]=1&user_id[]=67
    # GET /api/subjects/:subject_id/progress?user_id[]=1&user_id[]=67
    def index
      context = context(params)
      asset_reports = context.asset_reports
      asset_reports = filter_by_users(asset_reports, params[:user_id])

      respond_with asset_reports
    end

    protected

    def context(parameters)
      if parameters.has_key? :lecture_id
        Lecture.find(parameters[:lecture_id])
      else # :subject_id
        Subject.find(parameters[:subject_id])
      end
    end

    def filter_by_users(asset_reports, users_ids)
      if users_ids.blank?
        asset_reports
      else
        asset_reports.includes(:enrollment).
          where(:enrollments => { :user_id => users_ids })
      end
    end
  end
end
