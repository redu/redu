class Page < ActiveRecord::Base

  # belongs_to :course
  has_one :course, :as => :courseable
  #TODO: se exite uma ocorrencia lesson associada um page!!
  has_one :lesson, :as => :lesson

  validates_presence_of :body

end
