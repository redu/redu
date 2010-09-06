xml.instruct! 
xml.graph_data do
  xml.nodes do 
     xml.node( # nó central
      "id" => "user_"+ @user.id.to_s, 
      "label" => @user.login, 
      "tooltip" => @user.login,
      "graphic_type" => "image",
      "graphic_image_url" => application_url[0..application_url.length-2] + @user.avatar.url(:thumb)
      )
      
    for activity in @activities
      # user node
      xml.node(
      "id" => "user_"+ activity.user_id.to_s, 
      "label" => activity.user_id.to_s,#activity.activityin, 
      "tooltip" => activity.user_id.to_s#activity.activityin
#      "graphic_type" => "image", # TODO avatar??
#      "graphic_image_url" => application_url[0..application_url.length-2] + activity.user.avatar.url(:thumb)
      )
      
      # task node
      xml.node(
      "id" => activity.logeable_type.downcase + "_" + activity.logeable_id.to_s, 
      "label" => activity.logeable_name,
      "tooltip" => activity.logeable_name,
      "url" => application_url[0..application_url.length-2] + '/'+activity.logeable_type.downcase.pluralize + "/" + activity.logeable_id.to_s#url_for(activity.logeable)
      )
    end
  end
  
  xml.edges do
     for activity in @activities
       if activity.user_id != @user.id 
        #user follows user
        xml.edge(     # TODO evitar arestas duplicadas
        "id" => "follow_" + activity.id.to_s,
        "tail_node_id" => "user_" + @user.id.to_s,
        "head_node_id" => "user_"+ activity.user_id.to_s,
        "tooltip" => "segue",
        "edge_line_color" => "#0000ff",
        "edge_line_thickness" => "1"
        )
      end
      #user to object
       xml.edge(
      "id" =>  "activity_" + activity.id.to_s,
      "tail_node_id" => "user_"+ activity.user_id.to_s,
      "head_node_id" => activity.logeable_type.downcase + "_" + activity.logeable_id.to_s,
      "tooltip" => activity.log_action, #TODO mensagem de acordo com a log_action 
      #"bidirectional" => "true",
      "arrowhead"=>"false",
      "edge_line_color" => "#ff0000",
      "edge_line_thickness" => "1"
      )
     end
  end
end