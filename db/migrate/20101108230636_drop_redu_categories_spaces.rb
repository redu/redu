# -*- encoding : utf-8 -*-
class DropReduCategoriesSpaces < ActiveRecord::Migration
  
	def self.up
		drop_table :redu_categories_spaces
  end

  def self.down
		create_table "redu_categories_spaces", :id => false, :force => true do |t|
		  t.integer "redu_category_id"
		  t.integer "space_id"
		end
  end
end
