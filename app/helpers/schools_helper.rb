module SchoolsHelper
  
  def owner_link
    if @school.owner
      link_to @school.owner.display_name, @school.owner
    else
      if current_user.can_manage? @school
        'Sem dono ' + link_to("(pegar)", take_ownership_school_path)
      else
        'Sem dono'  
      end
      # e se ninguem estiver apto a pegar ownership?
    end
    
  end
  
  
  def columnize_categories(number_of_columns = 3)
    
   @categories = ReduCategory.find(:all)
   
    html = ''
    
   breakdiv = @categories.size/number_of_columns + 1
   
   @translated_categories = @categories.each {|c| c.name = c.name.downcase.gsub(' ','_').to_sym.l }
   @translated_categories.sort! { |a,b| a.name <=> b.name }
   
   
   
   @translated_categories.each_with_index do |category, idx| 
     html += (idx%breakdiv == 0 and idx != 0) ? '</div>' : ''
     html +=  (idx%breakdiv == 0) ? '<div style="float: left;">' : ''
     html +=  '<div>'
     html +=  check_box_tag "school[category_ids][]", category.id, @school.categories.include?(category) 
     html += category.name#.downcase.gsub(' ','_').to_sym.l #eita carai :P
     html += '</div>'
    
  end 
  html += '</div>' 
    
  end
  
  
  def subscription_link
    membership = current_user.get_association_with @school
    
    if membership and membership.status == 'approved' # já é membro
      link_to "Abandonar", unjoin_school_path, 
        :class => "participar_rede button" , 
        :confirm => "Você tem certeza que quer deixar essa rede?"
    else 
       case @school.subscription_type 
        
        when 1 # anyone can join
        link_to "Participar", join_school_path, :class => "participar_rede button" 
      when 2 # moderated
        if membership.status == 'pending'
          "(em moderação)"
        else
          link_to "Participar", join_school_path, :class => "participar_rede button"
        end
         
        when 3 #key
        link_to "Participar", "#", {:class => "participar_rede button", :onclick => "toggleAssociateBox();false;"} 
      end
      
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
  
  def teachers_preview(school, size = nil)
    sql = "SELECT u.login, u.login_slug FROM users u " \
          "INNER JOIN user_school_associations a " \
          "ON u.id = a.user_id " \
          "AND a.role_id = #{Role[:teacher].id} " \
          "WHERE a.school_id = #{school.id} LIMIT #{size or 12} "
          
    User.find_by_sql(sql)
  end
  
  def waiting_bulletins_count
    Bulletin.count(:conditions => ["state LIKE ?", "waiting"])
  end
  
end
