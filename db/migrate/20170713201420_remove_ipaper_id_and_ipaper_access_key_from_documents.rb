class RemoveIpaperIdAndIpaperAccessKeyFromDocuments < ActiveRecord::Migration

  def down
    add_column :documents, :ipaper_access_key, :string
    add_column :documents, :ipaper_id, :integer
  end
end
