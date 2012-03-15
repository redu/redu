module Vis
  class DashboardController < VisualizationsController

    # Requisição default pega o primeiro professor da lista do curso
    def teacher_participation
      # params [:id_course]
      @course = Course.find(params[:course_id])
      authorize! :teacher_participation, @course
      @teachers = @course.teachers

      # only if there is teachers
      if @teachers.empty?
        self.generate_erro("Não existem professores neste curso")
      else
        @uca = @teachers.first.get_association_with(@course)
        @participation = TeacherParticipation.new(@uca)
        self.generate_json
      end
    end

    # Interação do usuário
    def teacher_participation_interaction
      if params[:date_start].to_date < params[:date_end].to_date
        # params [:id_teacher]
        @course = Course.find(params[:course_id])
        authorize! :teacher_participation_interaction, @course
        @teacher = @course.teachers.find(params[:teacher_id])
        @uca = @teacher.get_association_with(@course)
        @participation = TeacherParticipation.new(@uca)

        # params [:time_start, :time_end] => time (format): "year-month-day"
        @participation.start = params[:date_start].to_date
        @participation.end = params[:date_end].to_date

        # params [:spaces[id's]]
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
