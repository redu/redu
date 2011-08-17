class Status < ActiveRecord::Base

  belongs_to :statusable, :polymorphic => true
  belongs_to :user
  has_many :answers, :as => :in_response_to
  has_many :observers, :through => :status_user_associations
  has_many :status_user_associations, :dependent => :destroy

end
