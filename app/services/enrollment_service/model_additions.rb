module EnrollmentService
  module ModelAdditions
    extend ActiveSupport::Concern

    # Matricula o usuário com o role especificado. Retorna true ou false
    # dependendo do resultado
    def enroll(users=nil, role=Role[:member])
      users = users.respond_to?(:map) ? users : [users]
      self.class.enroll(users, [self], role)
    end

    # Desmatricula o usuário
    def unenroll(user)
      enrollment = user.get_association_with(self)
      enrollment.destroy
    end

    def enrolled?(user)
      !user.get_association_with(self).nil?
    end

    module ClassMethods
      def enroll(users, subjects, role=Role[:member], options = {})
        create_enrollments(users, subjects, role)

        subject_ids = map_ids(subjects)
        enrollments = Enrollment.
          where(:subject_id => subject_ids, :user_id => map_ids(users))
        lectures = Lecture.where(:subject_id => subject_ids).
          select("id, subject_id")

        create_asset_reports(lectures, enrollments)
        send_state_to_vis(enrollments)

        enrollments
      end

      def vis_client=(client)
        @@vis_client = client
      end

      def vis_client
        @@vis_client ||= VisClient
      end

      private

      def create_enrollments(users, subjects, role=Role[:member])
        users_and_roles = users.map { |u| [u, role.to_s] }

        enrollments = CreateEnrollment.new(:subject => subjects)
        enrollments.create(users_and_roles)
      end

      def create_asset_reports(lectures, enrollments=nil)
        asset_reports = AssetReportService.new(:lecture => lectures)
        asset_reports.create(enrollments)
      end

      def map_ids(resources)
        resources.map(&:id).uniq
      end

      def send_state_to_vis(enrollments)
        url = "/hierarchy_notifications.json"
        vis_client.notify_delayed(url, "enrollment", enrollments)
      end
    end
  end
end
