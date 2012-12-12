module AuthlogicSpecHelper
  def login_as(user)
    controller.stub(:current_user) { user }
    controller.stub(:current_user_session) { UserSession.create(user) }
  end
end
