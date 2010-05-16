module SchoolsHelper
  
  
  def subscription_link
    if not @school.users.include?(current_user) #TODO verificar se nao esta pending
      
      case @school.subscription_type 
        
        when 1 # anyone can join
        link_to "PARTICIPAR", join_school_path, :class => "participar_rede" 
        when 2 # moderated
        link_to "PARTICIPAR", join_school_path, :class => "participar_rede" 
        when 3 #key
        link_to "PARTICIPAR", "#", {:class => "participar_rede", :onclick => "toggleAssociateBox();false;"} 
      end
      
    else 
      link_to "ABADONAR", unjoin_school_path, :class => "participar_rede" , :confirm => "Você tem certeza que quer deixar essa rede?"
    end 
    
  end
  
  
   # used to know if a topic has changed since we read it last
  def recent_topic_activity(topic)
    return false if not logged_in?
    return false unless last_active || session[:topics]
    
    return topic.replied_at > (last_active || session[:topics][topic.id])
  end 
  
  # used to know if a forum has changed since we read it last
  def recent_forum_activity(forum)
    return false unless logged_in? && forum.topics.first
    return false unless last_active || session[:forums]
     
    return forum.recent_topics.first.replied_at > (last_active || session[:forums][forum.id])
  end
  
  def icon_and_color_and_post_for(topic)
    icon = "comment"
    color = ""
    post = ''
    if topic.locked?
      icon = "lock" 
      post = ", "+:this_topic_is_locked.l
      color = "darkgrey"
    end  
    [icon, color, post  ]
  end
  
  
end
