class MetroArea < ActiveRecord::Base
  
  validates_presence_of :country_id
  validates_presence_of :name
 
  has_many :users
  belongs_to :state
  belongs_to :country
  
  def to_s
    name
  end

end
