module StatusVisNotification
  include VisClient

  def send_to_vis(status)
    unless status.type == "Log"
      params = build_hash_to_vis(status)
      send_async_info(params, Redu::Application.config.vis_client[:url])
    end
  end


  protected

  def build_hash_to_vis(status)
    case status.statusable.class.to_s
    when "Lecture"
      course = status.statusable.subject.space.course

      options = {
        :lecture_id => status.statusable_id,
        :subject_id => status.statusable.subject.id,
        :space_id => status.statusable.subject.space.id,
        :course_id => course.id,
      }

      params = fill_params(status, options)
    when "Space"
      options = {
        :lecture_id => nil,
        :subject_id => nil,
        :space_id => status.statusable.id,
        :course_id => status.statusable.course.id,
      }

      params = fill_params(status, options)
    when "Activity", "Help"
      statusable = status.statusable
      case statusable.statusable.class.to_s
      when "Lecture"
        course = statusable.statusable.subject.space.course
        options = {
          :lecture_id => statusable.statusable_id,
          :subject_id => statusable.statusable.subject.id,
          :space_id => statusable.statusable.subject.space.id,
          :course_id => course.id,
        }

        params = fill_params(status, options)
      when "Space"
        course = statusable.statusable.course
        options = {
          :lecture_id => nil,
          :subject_id => nil,
          :space_id => statusable.statusable_id,
          :course_id => course.id,
        }

        params = fill_params(status, options)
      end
    else
      nil
    end

    params
  end

  protected

  def fill_params(status, options = {})
    params = {
      :user_id => status.user_id,
      :type => get_type(status),
      :status_id => status.id,
      :statusable_id => status.statusable_id,
      :statusable_type => status.statusable_type,
      :in_response_to_id => status.in_response_to_id,
      :in_response_to_type => status.in_response_to_type,
      :created_at => status.created_at,
      :updated_at => status.updated_at
    }
    params.merge(options)
  end

  def get_type(status)
    if status.type == "Help" or status.type == "Activity"
      status.type.downcase
    elsif status.type == "Answer"
      if status.statusable.type == "Help"
        "answered_help"
      else
        "answered_activity"
      end
    else
      nil
    end
  end

end
