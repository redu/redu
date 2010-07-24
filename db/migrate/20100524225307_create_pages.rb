class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.text :body
      t.integer :course_id
      t.timestamps
    end
  end

  def self.down
    drop_table :pages
  end
end
