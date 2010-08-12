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
      
    for log in @logs
      # user node
      xml.node(
      "id" => "user_"+ log.user_id.to_s, 
      "label" => log.user_id.to_s,#log.login, 
      "tooltip" => log.user_id.to_s#log.login
#      "graphic_type" => "image", # TODO avatar??
#      "graphic_image_url" => application_url[0..application_url.length-2] + log.user.avatar.url(:thumb)
      )
      
      # task node
      xml.node(
      "id" => log.logeable_type.downcase + "_" + log.logeable_id.to_s, 
      "label" => log.logeable_name,
      "tooltip" => log.logeable_name,
      "url" => application_url[0..application_url.length-2] + '/'+log.logeable_type.downcase.pluralize + "/" + log.logeable_id.to_s#url_for(log.logeable)
      )
    end
  end
  
  xml.edges do
     for log in @logs
       if log.user_id != @user.id 
        #user follows user
        xml.edge(     # TODO evitar arestas duplicadas
        "id" => "follow_" + log.id.to_s,
        "tail_node_id" => "user_" + @user.id.to_s,
        "head_node_id" => "user_"+ log.user_id.to_s,
        "tooltip" => "segue",
        "edge_line_color" => "#0000ff",
        "edge_line_thickness" => "1"
        )
      end
      #user to object
       xml.edge(
      "id" =>  "log_" + log.id.to_s,
      "tail_node_id" => "user_"+ log.user_id.to_s,
      "head_node_id" => log.logeable_type.downcase + "_" + log.logeable_id.to_s,
      "tooltip" => log.action, #TODO mensagem de acordo com a action 
      #"bidirectional" => "true",
      "arrowhead"=>"false",
      "edge_line_color" => "#ff0000",
      "edge_line_thickness" => "1"
      )
     end
  end
end