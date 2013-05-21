# -*- encoding : utf-8 -*-
class RecoveryEmail
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :email

  validates_format_of :email, :with => /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/

  def initialize(attributes = {})
    self.email= attributes.try(:[], :email)
  end

  def persisted?
    false
  end

  def mark_email_as_invalid!
    errors.add(:email, :invalid)
  end
end
