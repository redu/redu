module LectureRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia

  property :id
  property :name
  property :created_at
  property :type
  property :view_count
  property :position
  property :rate_average, :from => :rating
  property :position
  property :lectureable, :extend => PolymorphicRepresenter

  def type
    self.lectureable.class.to_s
  end

  link :self do
    api_lecture_url(self)
  end

  link :next_lecture do
    api_lecture_url(self.next_item) unless self.last_item?
  end

  link :previous_lecture do
    api_lecture_url(self.previous_item) unless self.first_item?
  end

  link :subject do
    api_subject_url(self.subject)
  end
end
