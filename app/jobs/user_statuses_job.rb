class UserStatusesJob
  attr_accessor :user_id, :status_id

  def initialize(user_id, status_id)
    @user_id = user_id
    @status_id = status_id
  end

  def perform
    user = User.find_by_id(user_id)
    status = Status.find_by_id(status_id)

    if user && status
      if status.is_a?(Log) and status.logeable_type == "Friendship"
        Status.associate_with(status, status.logeable.user.friends.select("users.id") - [status.logeable.friend])
      else
        Status.associate_with(status, user.friends.select("users.id"))
        Status.associate_with(status, status.statusable.friends.select("users.id"))
      end
    end
  end
end
