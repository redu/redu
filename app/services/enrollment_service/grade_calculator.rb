module EnrollmentService
  class GradeCalculator < Struct.new(:asset_reports)
    # asset_reports_id_and_done [[enrollment_id, done]]
    def calculate_grade
      group_by_enrollment_id.map do |enrollment_id, asset_reports|
        total = asset_reports.size
        done = asset_reports.select { |(_, done)| done == true }.size

        if total == done
          grade = 100
          graduated = true
        else
          grade = (( done.to_f * 100 ) / total)
          graduated = false
        end

        [enrollment_id, grade, graduated]
      end
    end

    private

    def group_by_enrollment_id
      enrollment_id_and_done_pairs.group_by(&:first)
    end

    # [[:enrollment_id, :done]]
    def enrollment_id_and_done_pairs
      if asset_reports.is_a? ActiveRecord::Relation
        asset_reports.values_of(:enrollment_id, :done)
      else
        asset_reports.map { |as| [as.enrollment_id, as.done] }
      end
    end
  end
end
