module EnrollmentService
  # Responsvável por notificar Vis sobre a mudança de estado de Enrollment#graduated
  class EnrollmentStateManager < Struct.new(:enrollments)
    def notify_vis_if_enrollment_change(&block)
      prev_graduated = pluck_columns

      yield if block_given?

      reload!
      post_graduated = pluck_columns
      notify_diff(prev_graduated, post_graduated)
    end

    private

    def notify_diff(prev, post)
      finalized, unfinalized = diff(prev, post)

      unless finalized.empty?
        service_facade.
          notify_subject_finalized(Enrollment.where(:id => finalized))
      end

      unless unfinalized.empty?
        service_facade.
          notify_remove_subject_finalized(Enrollment.where(:id => unfinalized))
      end
    end

    def diff(prev, post)
      zip = prev.sort.zip(post.sort)
      finalized = []
      unfinalized = []
      zip.each do |(_, prev_graduated), (id, post_graduated)|
        next if prev_graduated == post_graduated

        if prev_graduated && !post_graduated
          unfinalized << id
        else
          finalized << id
        end
      end

      [finalized, unfinalized]
    end

    def pluck_columns(*columns)
      columns = [:id, :graduated] if columns.empty?

      if enrollments.is_a? ActiveRecord::Relation
        enrollments.values_of(*columns)
      else
        enrollments.map { |e| columns.map { |c| e.send(c) } }
      end
    end

    def reload!
      ids = pluck_columns(:id)
      enrollments = Enrollment.where(:id => ids)
    end

    def service_facade
      EnrollmentService::Facade.instance
    end
  end
end
