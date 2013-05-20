# -*- encoding : utf-8 -*-
class CreatePartnerUserAssociations < ActiveRecord::Migration
  def self.up
    create_table :partner_user_associations do |t|
      t.belongs_to :partner
      t.belongs_to :user
      t.timestamps
    end
  end

  def self.down
    drop_table :partner_user_associations
  end
end
