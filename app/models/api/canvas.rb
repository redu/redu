module Api
  class Canvas < ActiveRecord::Base
    belongs_to :user
    belongs_to :client_application
    # Remover depois que testar o script, lembrar de criar uma migration para remover no banco de dados
    belongs_to :container, :polymorphic => true
    has_one :lecture, :as => :lectureable

    validates_presence_of :client_application
    validates :url, :url => true, :allow_nil => true

    def current_url
      return self.url if self.url
      self.client_application.try(:url)
    end
  end
end
