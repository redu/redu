# -*- encoding : utf-8 -*-
class CreatePartnerEnvironmentAssociations < ActiveRecord::Migration
  def self.up
    create_table :partner_environment_associations do |t|
      t.belongs_to :environment
      t.belongs_to :partner

      t.column :cnpj, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :partner_environment_associations
  end
end
