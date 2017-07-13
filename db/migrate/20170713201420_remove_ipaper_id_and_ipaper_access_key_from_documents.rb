class RemoveIpaperIdAndIpaperAccessKeyFromDocuments < ActiveRecord::Migration
  def up
    remove_column :documents
    remove_column :documents
  end

  def down
    add_column :documents, :ipaper_access_key, :string
    add_column :documents, :ipaper_id, :integer
  end
end
