# -*- encoding : utf-8 -*-
class Error
  attr_accessor :error

  def initialize(msg)
    @error = msg
  end
end
