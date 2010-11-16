class Favorite < ActiveRecord::Base
  belongs_to :favoritable, :polymorphic => true
  belongs_to :user
end
