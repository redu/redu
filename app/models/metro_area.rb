class MetroArea < ActiveRecord::Base
  has_many :users
  belongs_to :state
  belongs_to :country

  validates_presence_of :country_id
  validates_presence_of :name

  def to_s
    name
  end

end
