module EnrollmentService
  class AssetReportService
    attr_reader :lectures

    def initialize(opts={})
      @lectures = opts.delete(:lecture)
      @lectures = @lectures.respond_to?(:map) ? @lectures : [@lectures]
    end

    # Cria AssetReport entre os User do Subject e as Lecture passadas na
    # inicialização.
    # Parâmetros:
    #   - Opcional: ARel representando Enrollment para os quais AssetReport
    #     serão criados.
    def create(enrollments=nil)
      values = values_from_enrollments(enrollments)
      importer.insert(values)
    end

    def importer
      @importer ||= AssetReportBulkMapper.new
    end

    protected

    def values_from_enrollments(enrollments)
      pairs = enrollment_id_and_subject_id_pairs(enrollments)
      lecture_ids = lectures.map(&:id)

      pairs.reduce([]) do |memo, (enrollment_id, subject_id)|
        lecture_ids.each { |id| memo << [subject_id, id, enrollment_id] }
        memo
      end
    end

    def enrollment_id_and_subject_id_pairs(enrollments_arel)
      subject_ids = lectures.map(&:subject_id).uniq
      arel = enrollments_arel || Enrollment.where(:subject_id => subject_ids)
      arel.values_of(:id, :subject_id)
    end
  end
end
