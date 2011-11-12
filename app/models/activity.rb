class Activity < Status
  validates_presence_of :text
  validates_length_of :text, :maximum => 800

  def respond(attrs, user)
    answer = self.answers.new do |a|
      a.attributes = attrs
      a.statusable = self
      a.user = user
    end

    self.update_attribute(:updated_at, Time.zone.now) if answer.save

    answer
  end
end
