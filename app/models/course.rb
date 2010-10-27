class Course < ActiveRecord::Base
  belongs_to :environment

  validates_presence_of :name

  def define_path
    self.path = self.name.slugify unless self.name.empty?
  end

  protected
  def slugify
    returning self.downcase.gsub(/'/, '').gsub(/[^a-z0-9]+/, '-') do |slug|
      slug.chop! if slug.last == '-'
    end
  end

end
