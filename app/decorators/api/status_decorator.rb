module StatusDecorator
  extend ActiveSupport::Concern

  def extended(base)
    base.class_eval do
      validates :statusable_type, :inclusion => { :in => ['Lecture'] }
    end
  end
end
