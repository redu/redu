# -*- encoding : utf-8 -*-
class TourSetting < UserSetting
  classy_enum_attr :view_mural, :enum => 'Privacy', :default => 'friends'
  serialize :explored
  attr_protected :explored

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
  # visited?("/ensine", "#basic-guide")
  # => true
  def visited?(*urls)
    return false unless self.explored

    urls.collect { |url| self.explored.include?(url) }.inject(:&)
  end


  # Indicates if at least one passed url or identifier was visited
  #
  # visited_at_least_one?("/ensine", "#basic-guide")
  # => true
  def visited_at_least_one?(*urls)
    return false unless self.explored

    urls.collect { |url| self.explored.include?(url) }.inject(:|)
  end
end
