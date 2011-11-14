module ExercisesHelper
  def period_of_time(ms)
    distance_in_seconds = (ms/1000).round
    distance_in_minutes = (distance_in_seconds/60).round

    case distance_in_seconds
    when (0..59)
      { :unit => "segundos", :value => distance_in_seconds }
    else
      { :unit => "minutos", :value => distance_in_minutes }
    end
  end
end
