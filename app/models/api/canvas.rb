module Api
  class Canvas < ActiveRecord::Base
    belongs_to :user
    belongs_to :client_application
    belongs_to :container, :polymorphic => true
  end
end
