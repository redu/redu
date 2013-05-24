# -*- encoding : utf-8 -*-
module EnrollmentService
  class AssetReportEntityService
    attr_reader :lectures

    def initialize(opts={})
      @lectures = opts.delete(:lecture)
      @lectures = @lectures.respond_to?(:map) ? @lectures : [@lectures]
    end

    # Cria AssetReport entre os User do Subject e as Lecture passadas na
    # inicialização.
    #
    # Parâmetros:
    #   - enrollments: Enrollments para os quais AssetReports serão criados.
    def create(enrollments=nil)
      values = values_from_enrollments(enrollments)
      enrollments_ids = values.map(&:last).uniq

      importer.insert(values)

      get_asset_reports_for(enrollments_ids)
    end

    def importer
      @importer ||= AssetReportBulkMapper.new
    end

    # Destrói AssetReport dos Enrollments com a(s) Lecture(s).
    # Parâmetros:
    #   - enrollments: Enrollments que devem ter os asset reports com a(s)
    #   lecture(s) destruídos.
    #
    # Atenção: Não invoca callbacks (nem remove associações :dependent).
    def destroy(enrollments)
      assets = AssetReport.where(lecture_id: lectures,
                                 enrollment_id: enrollments)

      AssetReport.delete_all(["id IN (?)", assets.values_of(:id)])
    end

    def get_asset_reports_for(enrollments)
      AssetReport.where(lecture_id: lectures, enrollment_id: enrollments)
    end

    protected

    def values_from_enrollments(enrollments)
      pairs = enrollment_id_and_subject_id_pairs(enrollments)
      lecture_id_and_subject_id_pairs = lectures.map { |l| [l.id, l.subject_id] }

      # Cria os pares de acordo com a verificação de que a Lecture
      # pertence ao Subject
      pairs.reduce([]) do |memo, (enrollment_id, subject_id)|
        lecture_id_and_subject_id_pairs.each do |l_id, l_subject_id|
          if l_subject_id == subject_id
            memo << [subject_id, l_id, enrollment_id]
          end
        end
        memo
      end
    end

    def enrollment_id_and_subject_id_pairs(enrollments)
      if enrollments
        enrollments.map { |e| [e.id, e.subject_id] }
      else
        subject_ids = lectures.map(&:subject_id).uniq
        Enrollment.where(subject_id: subject_ids).values_of(:id, :subject_id)
      end
    end
  end
end
