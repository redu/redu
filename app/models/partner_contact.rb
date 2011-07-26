class PartnerContact
  include ActiveModel::Validations
  include ActiveModel::MassAssignmentSecurity

  attr_accessor :environment_name, :course_name, :email, :category, :details

  validates_presence_of :environment_name, :course_name, :email, :category
  validates_format_of :email, :with => /^[A-Z0-9._%+-]+@[A-Z0-9.-]+.[A-Z]{2,4}$/i

  def initialize(attributes={})
    attributes.each do |key, value|
      send("#{key}=", value)
    end
  end

  def attributes=(values)
    sanitize_for_mass_assignment(values).each do |k, v|
      send("#{k}=", v)
    end
  end

  def deliver
    UserNotifier.partner_environment_notice(self).deliver if self.valid?
  end
end
