# -*- encoding : utf-8 -*-
class AssetReportCacheObserver < ActiveRecord::Observer
  include ViewCaches
  observe AssetReport

  def before_update(asset_report)
    if asset_report.done_changed?
      expire_space_lectures_item_for(asset_report.lecture,
                                     asset_report.enrollment.user)
    end
  end
end
