class Alternative < ActiveRecord::Base
  belongs_to :question
  has_many :choices, :dependent => :destroy
end
