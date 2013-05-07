module EnrollmentService
  module Jobs
    class CreateEnrollmentJob < LinkedJob
      def initialize(opts={})
        options.set(:user, opts.delete(:user))
        options.set(:subject, opts.delete(:subject))

        @extra = opts
      end

      def execute
        opts = {}
        opts[:role] = @extra[:role] if @extra[:role]
        subjects = options.arel_of(:subject)
        users = options.arel_of(:user)

        enrollments = facade.create_enrollment(subjects, users, opts) || []

        { :enrollments => enrollments }
      end

      def build_next_job(env)
        lectures = Lecture.where(:subject_id => subject_ids)
        CreateAssetReportJob.new(:lecture => lectures,
                                 :enrollment => env[:enrollments])
      end

      def user_ids
        options.ids(:user)
      end

      def subject_ids
        options.ids(:subject)
      end
    end
  end
end
