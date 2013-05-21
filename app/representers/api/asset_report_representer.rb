# -*- encoding : utf-8 -*-
module Api
  module AssetReportRepresenter
    include Roar::Representer::JSON
    include Roar::Representer::Feature::Hypermedia

    property :id
    property :finalized
    property :updated_at

    def finalized
      self.done
    end

    link :self do
      api_asset_report_url(self)
    end

    link :user do
      api_user_url(self.enrollment.user)
    end

    link :lecture do
      api_lecture_url(self.lecture)
    end

    link :subject do
      api_subject_url(self.subject)
    end
  end
end
