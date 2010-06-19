class AddPolymorphismToLessons < ActiveRecord::Migration
  def self.up
    add_column :lessons, :lesson_type, :string
    add_column :lessons, :lesson_id, :integer
  end

  def self.down
  end
end
