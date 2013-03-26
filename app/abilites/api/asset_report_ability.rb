module Api
  module AssetReportAbility
    extend ActiveSupport::Concern

    module InstanceMethods
      def asset_report_abilities(user)
        if user
          can(:manage, AssetReport) { |a| a.enrollment.user == user }
          can(:read, AssetReport) { |a| a.enrollment.user == user }
        end
      end
    end
  end
end
