module RequestsHelper
  def login_as(user)
    visit '/'
    fill_in 'user_session_login', :with => user.login
    fill_in 'user_session_password', :with => user.password
    click_on 'Entrar'
  end
end
