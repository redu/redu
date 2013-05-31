# -*- encoding : utf-8 -*-
module EnrollmentService
  module SubjectAdditions
    module ModelAdditions
      extend ActiveSupport::Concern

      # Matricula um ou mais User no Subject. Caso nenhum parâmetro seja passado
      # os Users do Space serão matriculados com os mesmos papéis.
      #
      # options:
      #   - role: papél dos Users. Só é levado em consideração quado o parâmetro
      #   user é passado. Caso seja omitido o papél sera Role[:member]
      def enroll(users=nil, opts = {})
        options = {}
        if users
          options = { role: Role[:member] }.merge(opts)
          options[:users] = (users.respond_to?(:map) ? users : [users])
        end

        self.class.enroll(self, options)
      end

      # Desmatricula um ou mais User do Subject.
      #
      # Parâmetros:
      #   - users: Users que serão desmatriculados.
      def unenroll(users)
        self.class.unenroll([self], users)
      end

      def enrolled?(user)
        !user.get_association_with(self).nil?
      end

      module ClassMethods
        # Matricula usuários em um ou mais Subjects
        # Parâmetros:
        #   subjects: Um ou mais Subject aos quais o usuário será matriculado.
        #   Caso esta opção seja utilizada sem a opção :role, os papéis serão
        #   inferidos a partir do papel do usuário no Space.
        #
        # options:
        #   - role: Papéis dos usuários
        #   - users: Users que serão matriculados. Caso seja omitido os usuários
        #   do Space serão matriculados com o mesmo papél.
        def enroll(subject_or_subjects, options = {})
          subjects = subject_or_subjects.
            respond_to?(:map) ? subject_or_subjects : [subject_or_subjects]
          role = options[:role] || Role[:member]
          users = options[:users]

          delayed_enroll(subjects, users, role)
        end

        # Desmatricula usuários em um ou mais Subjects.
        #
        # Parâmetros:
        #   subjects: Subjects aos quais o usuário será desmatriculado.
        #   user_or_users: Um ou mais Users que serão desmatriculados.
        def unenroll(subjects, user_or_users)
          users = user_or_users.respond_to?(:map) ? user_or_users :
            [user_or_users]

          enrollments = Enrollment.where(subject_id: subjects,
                                         user_id: users)
          lectures = Lecture.where(subject_id: subjects)

          enrollment_service.destroy_asset_report(lectures, enrollments)
          enrollment_service.destroy_enrollment(subjects, users)
        end

        private

        def delayed_enroll(subjects, users, role)
          job = Jobs::CreateEnrollmentJob.
            new(subject: subjects, user: users, role: role.to_sym)
          enqueue(job)
        end

        def enqueue(job)
          Delayed::Job.enqueue(job, queue: "hierarchy-associations")
        end
      end
    end
  end
end
