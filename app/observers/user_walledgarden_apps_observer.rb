class UserWalledgardenAppsObserver < ActiveRecord::Observer
  # Observer responsável pela criação de OAuth2Tokens ClientApplications do
  # walledgarden.
  observe User

  def after_create(user)
    applications.each do |app|
      Oauth2Token.create(:client_application => app, :user => user)
    end
    user.update_attributes({ :updated_at => Time.zone.now })
  end

  protected

  def applications
    ClientApplication.where(:walledgarden => true)
  end
end
