# -*- encoding : utf-8 -*-
class AddCompanyNameToPartnerEnvironmentAssociations < ActiveRecord::Migration
  def self.up
    add_column :partner_environment_associations, :company_name, :string
  end

  def self.down
    remove_column :partner_environment_associations, :company_name
  end
end
