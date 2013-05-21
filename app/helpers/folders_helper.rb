# -*- encoding : utf-8 -*-
# Helper methods for folder views
module FoldersHelper
  # Creates a link in the folder list view. Clicking the link will order the contents of a folder
  # by the field supplied in order_by. If the contents of the folder are already ordered by 'order_by',
  # clicking the link will reverse the order. This helper only generates the links for this. The actual
  # functionality is implemented in FolderController.list


  def link_order(name, order_by)
    if params[:order] == nil and params[:order_by] == order_by
      link_to(name, space_folders_path(:space_id => params[:space_id],
                                       :id => params[:id],
                                       :order_by => order_by,
                                       :order => 'DESC'),
             :remote => true) + image_tag('asc.png')
    elsif params[:order] and params[:order_by] == order_by
      link_to(name, space_folders_path(:id => params[:id],
                                      :space_id => params[:space_id],
                                      :order_by => order_by),
             :remote => true) + image_tag('desc.png')
    else
      link_to(name, space_folders_path(:id => params[:id],
                                      :space_id => params[:space_id],
                                      :order_by => order_by),
             :remote => true)
    end
  end

  def bytes_to_kb(size_in_bytes)
     "%0.2f" % (size_in_bytes / (1024.0));
  end

  def folder_path(folder)
    path = h(folder.name)

    until folder.parent == nil
      folder = folder.parent
      path = link_to(h(folder.name),
                            space_folders_path(folder.space, :id => folder.id),
                            :remote => true,
                            :method => :get ) + ' > ' + path
    end

    return path.sub("root", "Arquivos de Apoio")
  end
end
