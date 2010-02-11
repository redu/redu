class Status < ActiveRecord::Base
  
  belongs_to :in_response_to, :polymorphic => true
  belongs_to :user
  
  validates_presence_of(:text)
  
end
