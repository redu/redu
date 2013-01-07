class UnjoinUserJob
  def initialize(opts)
    @course_id = opts[:course].try(:id)
    @user_id = opts[:user].try(:id)
  end

  def perform
    course = Course.find_by_id(@course_id)
    user = User.find_by_id(@user_id)

    if course && user
      course.unjoin(user)
    end
  end
end
