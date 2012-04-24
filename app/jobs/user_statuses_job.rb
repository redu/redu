class UserStatusesJob
  attr_accessor :user_id, :status_id

  def initialize(user_id, status_id)
    @user_id = user_id
    @status_id = status_id
  end

  def perform
    user = User.find(user_id)
    status = Status.find(status_id)

    if user && status
      Status.associate_with(status, user.friends.select("users.id"))
      Status.associate_with(status, status.statusable.friends.select("users.id"))
    end
  end
end
