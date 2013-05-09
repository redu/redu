module Api
  class AssetReportsController < Api::ApiController
    def show
      asset_report = AssetReport.find(params[:id])
      authorize! :read, asset_report

      respond_with asset_report
    end

    def update
      asset_report = AssetReport.find(params[:id])
      authorize! :manage, asset_report

      asset_report.done = params[:progress][:finalized].to_s
      asset_report.save
      asset_report.enrollment.update_grade!

      respond_with asset_report
    end

    # GET /api/lectures/:lecture_id/progress?users_ids[]=1&users_ids[]=67
    # GET /api/subjects/:subject_id/progress?users_ids[]=1&users_ids[]=67
    # GET /api/users/:user_id/progress?lectures_ids[]=1&lectures_ids[]=67
    # GET /api/users/:user_id/progress?subjects_ids[]=1&subjects_ids[]=67
    def index
      context = context(params)
      authorize! :manage, context

      asset_reports = context.asset_reports.includes(:lecture, :subject,
                                                     { :enrollment => :user })

      asset_reports = filter_by_users(asset_reports, params[:users_ids])
      asset_reports = filter_by(:lecture, asset_reports, params[:lectures_ids])
      asset_reports = filter_by(:subject, asset_reports, params[:subjects_ids])

      respond_with asset_reports
    end

    protected

    def context(parameters)
      if parameters.has_key? :lecture_id
        Lecture.find(parameters[:lecture_id])
      elsif parameters.has_key? :user_id
        User.find(parameters[:user_id])
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

    def filter_by(identifier, asset_reports, ids)
      if ids.blank?
        asset_reports
      else
        asset_reports.where("#{identifier.to_s}_id".to_sym => ids)
      end
    end
  end
end
