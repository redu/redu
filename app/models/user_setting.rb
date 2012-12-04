class UserSetting < ActiveRecord::Base
  belongs_to :user
  enumerate :view_mural, :with => Privacy
  serialize :explored

  # Keeps track of the visited urls or identifiers
  #
  # visit!("/ensine")
  # => true
  # visit!("#learn-environments")
  # => true
  def visit!(url)
    return true if visited?(url)

    self.explored ||= []
    self.explored << url
    self.save
  end

  # Indicates if the passed url or identifier was visited
  #
  # visited?("/ensine")
  # => true
  # visited?("#learn-environments")
  # => false
  def visited?(url)
    self.explored.try(:include?, url)
  end
end
