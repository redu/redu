class Acquisition < ActiveRecord::Base
  belongs_to :acquired_by, :polymorphic => true
  belongs_to :course
end
