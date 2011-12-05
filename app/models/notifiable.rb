class Notifiable < ActiveRecord::Base
	belongs_to :user

  def increment_counter
    self.counter = 0 if self.counter.nil?
    self.counter += 1
  end

  def reset_counter
    self.counter = 0
  end
end
