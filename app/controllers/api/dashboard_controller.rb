module Api
  class DashboardController < ApiController
    def teacher_participation
      # params [:id (course), :teacher (id), :spaces[id's], :time_start, :time_end]
      #
      # time (format): day_month_year

      @uca = User.find(params[:id_teacher]).get_association_with(Course.find(params[:id_course]))
      @participation = ::TeacherParticipation.new(@uca)

      @participation.generate!
      @participation.extend(TeacherParticipationRepresenter)

      respond_with @participation
    end
  end
end
