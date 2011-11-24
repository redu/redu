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

  # Creates a check box and checks/unchecks, disables it depending on the given parameters.
  # The name of the check box is based on the given type.
  # This helper method is used for show the permission in the folder list view.
  def CRUD_check_box(type, group_id, folder_id, disabled)
    case type
    when 'create'
      checked = true
      check_box('create_check_box', group_id, {:checked => checked, :disabled => disabled, :onclick => 'CheckRead(this.checked, ' + group_id.to_s + ')'})
    when 'read'
      checked = true
      check_box('read_check_box', group_id, {:checked => checked, :disabled => disabled, :onclick => 'UncheckCreateUpdateDelete(this.checked, ' + group_id.to_s + ')'})
    when 'update'
      checked = true
      check_box('update_check_box', group_id, {:checked => checked, :disabled => disabled, :onclick => 'CheckRead(this.checked, ' + group_id.to_s + ')'})
    when 'delete'
      checked = true
      check_box('delete_check_box', group_id, {:checked => checked, :disabled => disabled, :onclick => 'CheckRead(this.checked, ' + group_id.to_s + ')'})
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
