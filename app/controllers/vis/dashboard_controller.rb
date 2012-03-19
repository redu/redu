module Vis
  class DashboardController < VisualizationsController

    # Interação do usuário
    def teacher_participation_interaction
      if params[:date_start].to_date < params[:date_end].to_date
        # params [:course_id]
        @course = Course.find(params[:course_id])
        authorize! :teacher_participation_interaction, @course

        # params [:teacher_id]
        @teacher = @course.teachers.find(params[:teacher_id])
        @uca = @teacher.get_association_with(@course)
        @participation = TeacherParticipation.new(@uca)

        # params [:date_start, :date_end] => time (format): "year-month-day"
        @participation.start = params[:date_start].to_date
        @participation.end = params[:date_end].to_date

        # params [:spaces[id.to_s]]
        @spaces = params[:spaces].join(',').split(',')
        @participation.spaces = @uca.course.spaces.find(@spaces)

        self.generate_json
      else
        self.generate_erro("Intervalo de tempo inválido")
      end
    end

    protected

    def generate_erro(msg)
      @error = Error.new(msg)
      respond_to do |format|
        format.json { render :json => @error.extend(ErrorRepresenter)}
      end
    end

    def generate_json
      @participation.generate!
      @participation.extend(TeacherParticipationRepresenter)

      respond_to do |format|
        format.json { render :json => @participation }
      end
    end
  end
end
