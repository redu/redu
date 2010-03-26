class AccessKey < ActiveRecord::Base
  #belongs_to :user
 belongs_to :school
  #belongs_to :user_school_association, :dependent => :destroy
  has_one :user_school_association, :dependent => :destroy
  
  before_create :make_key_code
  
 validates_uniqueness_of :key
  
  
  protected
  
  def make_key_code(length = 6)
    self.key = Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by {rand}.join )[1..length]
  end
  
end
