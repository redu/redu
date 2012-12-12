module Api
  class Canvas < ActiveRecord::Base
    belongs_to :user
    belongs_to :client_application
    # Remover depois que testar o script, lembrar de criar uma migration para remover no banco de dados
    belongs_to :container, :polymorphic => true
    has_one :lecture, :as => :lectureable

    validates_presence_of :client_application
  end
end
