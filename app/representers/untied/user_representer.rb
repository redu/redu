module Untied
  module UserRepresenter
    # Utilizado para serializar modelo de User enviado pelo Untied
    include Roar::Representer::JSON

    self.representation_wrap = true

    property :id
    property :first_name
    property :last_name
    property :persistence_token
    property :login
    property :password_salt
    property :email
    property :crypted_password
    collection :walledgarden_client_applications, :from => :client_applications

    def walledgarden_client_applications
      oauth_tokens = self.tokens.joins(:client_application).
        includes(:client_application).
        where(:client_applications => { :walledgarden => true })

      oauth_tokens.collect do |t|
        {
          :name => t.client_application.name, :user_token => t.token,
          :secret => t.client_application.secret,
          :key => t.client_application.key
        }
      end
    end
  end
end
