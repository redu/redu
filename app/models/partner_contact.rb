class PartnerContact
  include ActiveModel::Validations
  include ActiveModel::MassAssignmentSecurity

  attr_accessor :environment_name, :course_name, :email, :category, :details,
    :migration, :billable_url

  validates_presence_of  :email, :category
  validates_format_of :email, :with => /^[A-Z0-9._%+-]+@[A-Z0-9.-]+.[A-Z]{2,4}$/i

  validates_presence_of :environment_name, :course_name, :unless => "self.migration"
  validates_presence_of :billable_url, :if => "self.migration"

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
    if self.valid?
      if self.migration
        UserNotifier.delay(:queue => 'email').
          partner_environment_migration_notice(self)
      else
        UserNotifier.delay(:queue => 'email').
          partner_environment_notice(self)
      end
    end
  end
end
