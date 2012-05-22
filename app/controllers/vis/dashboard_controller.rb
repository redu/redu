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

    def flare
      @json = {
        "name" => "flare",
        "children" =>
        [{"name" => "0", "grade" => 0.0, "size" => 10},
         {"name" => "1", "grade" => 1.0, "size" => 10},
         {"name" => "2", "grade" => 2.0, "size" => 130},
         {"name" => "3", "grade" => 3.0, "size" => 10},
         {"name" => "4", "grade" => 4.0, "size" => 10},
         {"name" => "5", "grade" => 5.0, "size" => 10},
         {"name" => "6", "grade" => 6.0, "size" => 50},
         {"name" => "7", "grade" => 7.0, "size" => 10},
         {"name" => "8", "grade" => 8.0, "size" => 10},
         {"name" => "9", "grade" => 9.0, "size" => 1}]
      }

      respond_to do |format|
        format.json { render :json => @json}
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
