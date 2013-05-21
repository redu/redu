# -*- encoding : utf-8 -*-
class Favorite < ActiveRecord::Base
  belongs_to :favoritable, :polymorphic => true
  belongs_to :user
end
