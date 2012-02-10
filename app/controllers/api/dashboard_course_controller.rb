module Api
  class DashboardController < ApiController
    def teacher_participation
      # params [:id (course), :teacher (id), :spaces[id's], :time_start, :time_end]
      @uca = current_user.get_association_with(@course)
      @respost = @uca.extend(TeacherParticipationRepresenter)
      respond_with @respost:q

    end
  end
end
