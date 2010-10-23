class BetaKey < ActiveRecord::Base

	# VALIDATIONS
  validates_uniqueness_of :key

	#	ASSOCIATIONS
  belongs_to :user
  before_create :make_key_code	

  protected

  def make_key_code(length = 6)
    self.key = Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by {rand}.join )[1..length]
  end
end
