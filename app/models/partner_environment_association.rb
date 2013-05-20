# -*- encoding : utf-8 -*-
class PartnerEnvironmentAssociation < ActiveRecord::Base
  belongs_to :partner
  belongs_to :environment, :dependent => :destroy

  validates_presence_of :cnpj, :address, :company_name
  validates_format_of :cnpj, :with => /^\d{2}.?\d{3}.?\d{3}\/?\d{4}\-?\d{2}$/

  accepts_nested_attributes_for :environment, :limit => 1

  def formatted_cnpj
    self.cnpj =~ /(\d{2})\.?(\d{3})\.?(\d{3})\/?(\d{4})-?(\d{2})/
    "#{$1}.#{$2}.#{$3}/#{$4}-#{$5}"
  end

  # Retorna o plano de um environment destruído
  def plan_of_dead_environment
    Plan.where(:billable_id => self.environment_id,
               :billable_type => "Environment").
               order("created_at DESC").limit(1).first
  end
end
