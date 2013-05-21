# -*- encoding : utf-8 -*-
class AddAddressToPartnerEnvironmentAssociations < ActiveRecord::Migration
  def self.up
    add_column :partner_environment_associations, :address, :string
  end

  def self.down
    remove_column :partner_environment_associations, :address
  end
end
