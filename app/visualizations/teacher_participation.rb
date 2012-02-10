class TeacherParticipation
  attr_accessor :lectures_created

  def initialize(uca)
    @uca = uca
    #@start = init_period
    #@end = end_period
  end

  # Todos os resultados tem que ser filtrados pelo período de tempo e pelas disciplinas selecionadas
  def generate!
    @user_id = @uca.user_id
    @course_id = @uca.course_id
    @duration = self.period_days

    # Criação da lista de disciplinas, passa o array de id's de params
    @spaces = @uca.course.spaces.where("id=?", [1])

    @lectures_created = @spaces
  end

  def lectures_created
   # @day = Time.new(@start_year, @start_month, @start_day)

    for d in 1..@duration
    #  @lecture[d] = @uca.user.lectures.where(:created_at => ())

    #  @day += (60*60*24)
    end
  end

  # Quantização de dias no intervalo dado
  def period_days
    @start_day = 20
    @start_month = 12
    @start_year = 2011

    @end_day = 19
    @end_month = 02
    @end_year = 2012

    @qtd_days = 0

    if(@start_year == @end_year)
      for m in @start_month..@end_month
        @qtd_days += Time.days_in_month(m,y)
      end
    else
      for y in @start_year..@end_year
        if(y == @start_year)
          for m in @start_month..12
            @qtd_days += Time.days_in_month(m,y)
          end
        elsif (y == @end_year)
          for m in 1..@end_month
            @qtd_days += Time.days_in_month(m,y)
          end
        else
          for m in 1..12
            @qtd_days += Time.days_in_month(m,y)
          end
        end
      end
    end

    @qtd_days = @qtd_days - ((@start_day - 1) + (Time.days_in_month(@end_month, @end_year) - @end_day))
  end
end
