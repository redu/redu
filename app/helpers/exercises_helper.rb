module ExercisesHelper
  def period_of_time(ms)
    distance_in_seconds = ms.round
    distance_in_minutes = (distance_in_seconds/60).round

    case distance_in_seconds
    when (0..59)
      { :unit => "segundos", :value => distance_in_seconds }
    else
      { :unit => "minutos", :value => distance_in_minutes }
    end
  end

  def detailed_period_of_time(seconds)
    distance_in_seconds = seconds.round
    distance_in_minutes = (distance_in_seconds/60).round
    distance_in_hours = (distance_in_minutes/60).round

    result = ""
    result += "#{distance_in_hours}h" unless distance_in_hours == 0
    result += "#{distance_in_minutes}m" unless distance_in_minutes == 0
    result += "#{distance_in_seconds}s" unless distance_in_seconds == 0
  end
end
