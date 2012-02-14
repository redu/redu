class PartnerEnvironmentAssociation < ActiveRecord::Base
  belongs_to :partner
  belongs_to :environment

  validates_presence_of :cnpj
  validates_format_of :cnpj, :with => /^\d{2}.?\d{3}.?\d{3}\/?\d{4}\-?\d{2}$/

  accepts_nested_attributes_for :environment, :limit => 1

  def formatted_cnpj
    self.cnpj =~ /(\d{2})\.?(\d{3})\.?(\d{3})\/?(\d{4})-?(\d{2})/
    "#{$1}.#{$2}.#{$3}/#{$4}-#{$5}"
  end
end
