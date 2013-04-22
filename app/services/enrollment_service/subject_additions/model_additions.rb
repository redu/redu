module EnrollmentService
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
        options = { :role => Role[:member] }.merge(opts)
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

        create_enrollment(subjects, users, :role => role)
        create_asset_report(subjects, users)

        # FIXME: fazer create_asset_report e create_enrollment retornarem
        # os asset reports e enrollments.
        if users
          enrollments = Enrollment.
            where(:subject_id => pluck_ids(subjects), :user_id => pluck_ids(users))
        else
          enrollments = Enrollment.where(:subject_id => pluck_ids(subjects))
        end

        notify_enrollment_creation(enrollments)

        enrollments
      end

      # Desmatricula usuários em um ou mais Subjects.
      #
      # Parâmetros:
      #   subjects: Subjects aos quais o usuário será desmatriculado.
      #   user_or_users: Um ou mais Users que serão desmatriculados.
      def unenroll(subjects, user_or_users)
        users = user_or_users.respond_to?(:map) ? user_or_users :
          [user_or_users]

        enrollments = Enrollment.where(:subject_id => subjects).select do |e|
          users.include? e.user
        end

        destroy_asset_report(subjects, enrollments)
        notify_enrollment_removal(enrollments)
        destroy_enrollment(subjects, users)
      end

      private

      # Cria Enrollment entre os User e Subject passados.
      # Parâmetros:
      #   - subjects (obrigatório): Lista de Subject ao qual os users
      #   serão matriculados
      #   - users (opcional): Lista de User que serão matriculados. Se omitido
      #   os usuários do Space serão matriculados
      # options:
      #   - role: Papel dos usuários
      def create_enrollment(subjects, users=nil, opts={})
        options = { :role => Role[:member] }.merge(opts)

        service = EnrollmentEntityService.new(:subject => subjects)

        if users
          users_and_roles = users.map { |u| [u, options[:role].to_s] }
          service.create(users_and_roles)
        else
          service.create
        end
      end

      # Cria AssetReport entre todas as Lectures dos Subjects passados e os
      # Users. Caso users seja omitido, todos os Users matriculados no Subject
      # serão utilizados.
      def create_asset_report(subjects, users=nil)
        subject_ids = pluck_ids(subjects)
        lectures = Lecture.
          where(:subject_id => subject_ids).select("id, subject_id")
        asset_reports = AssetReportEntityService.new(:lecture => lectures)

        if users
          enrollments = Enrollment.
            where(:subject_id => subject_ids, :user_id => pluck_ids(users))

          asset_reports.create(enrollments)
        else
          asset_reports.create
        end
      end

      def pluck_ids(resources)
        resources.map(&:id).uniq
      end


      # Notifica remoção de enrollments a Vis
      # Parâmetros:
      #   enrollments: Enrollments que serão enviados para Vis
      def notify_enrollment_removal(enrollments)
        vis_adapter = VisAdapter.new
        vis_adapter.notify_enrollment_removal(enrollments)
        graduated_enrollments = enrollments.select { |e| e.graduated? }
        vis_adapter.notify_graduated_enrollment_removal(graduated_enrollments)
      end

      # Notifica criação de enrollments a Vis
      # Parâmetros:
      #   enrollments: Enrollments que serão enviados para Vis
      def notify_enrollment_creation(enrollments)
        vis_adapter = VisAdapter.new
        vis_adapter.notify_enrollment_creation(enrollments)
      end

      # Destrói os enrollments entre os Subjects e Users
      # Parâmetros:
      #   subjects: Subjects que os Users serão desmatriculados
      #   users: Users que serão desmatriculados
      def destroy_enrollment(subjects, users)
        enrollment_service = EnrollmentEntityService.new(:subject => subjects)
        enrollment_service.destroy(users)
      end

      # Destrói os asset reports dos Enrollments nos Subjects
      # Parâmetros:
      #   subjects: Subjects que possuem as aulas
      #   enrollments: Enrollments que terão os asset reports removidos
      def destroy_asset_report(subjects, enrollments)
        lectures = Lecture.where(:subject_id => subjects).select("id")
        asset_report_service = AssetReportEntityService.new(:lecture => \
                                                            lectures)
        asset_report_service.destroy(enrollments)
      end
    end
  end
end
