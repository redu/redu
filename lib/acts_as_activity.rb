module ActsAsActivity
  extend ActiveSupport::Concern
  included do
    validates_presence_of :text
  end

  module InstanceMethods
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
end

