module EnrollmentService
  class GradeCalculator < Struct.new(:enrollments)
    # asset_reports_id_and_done [[enrollment_id, done]]
    def calculate_grade
      group_by_enrollment_id.map do |enrollment_id, asset_reports|
        total = asset_reports.size
        done = asset_reports.select { |(_, done)| done == true }.size

        grade = completeness(total, done)
        graduated = (grade == 100.0)

        [enrollment_id, grade, graduated]
      end
    end

    private

    # Cria agrupamento do tipo { :enrollment_id => [true, false, true...] }
    def group_by_enrollment_id
      empty_group = build_empty_enrollment_id_group
      empty_group.merge!(enrollment_id_and_done_pairs.group_by(&:first))
    end

    # [[:enrollment_id, :done]]
    def enrollment_id_and_done_pairs
      asset_reports.values_of(:enrollment_id, :done)
    end

    def asset_reports
      @asset_reports ||= AssetReport.where(:enrollment_id => enrollment_ids)
    end

    def enrollment_ids
      if enrollments.is_a? ActiveRecord::Relation
        enrollments.value_of(:id)
      else
        enrollments.map(&:id)
      end
    end

    def build_empty_enrollment_id_group
      enrollment_ids.reduce({}) do |memo, enrollment_id|
        memo[enrollment_id] ||= []
        memo
      end
    end

    def completeness(total, done)
      case total
      when 0 then 0
      when done then 100
      else
        (done.to_f * 100) / total
      end
    end
  end
end
