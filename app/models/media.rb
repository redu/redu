class Media < ActiveRecord::Base
  
  belongs_to :resources, :polymorphic => true
  
end
