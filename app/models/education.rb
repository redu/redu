class Education < ActiveRecord::Base
  belongs_to :educationable, :polymorphic => true, :dependent => :destroy
  belongs_to :user

  attr_protected :user

  validates_presence_of :educationable, :user
  validates_associated :educationable
end
