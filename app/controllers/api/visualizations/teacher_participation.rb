class TeacherParticipation
  attr_accessor :lectures_created

  def initialize(uca)
    @uca = uca
    #@start = init_period
    #@end = end_period
  end

  def generate!
    @user_id = @uca.user_id
    @course_id = @uca.course_id

    @lectures_createded = self.user.find(@user_id).lectures.count
  end
end
