module SchoolsHelper
  
  
  def submission_type(school)
    case school.submission_type
      when 1
        'Todos, sem moderação'
       when 2
        'Todos, com moderação'
        when 3
        'Apenas professores'
        end
  end
  
   def subscription_type(school)
    case school.subscription_type
      when 1
        'Livre'
       when 2
        'Moderado'
        when 3
        'Restrito'
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
      link_to(
      # image_tag("icons/house.gif") + 
       " Abandonar rede", unjoin_school_path, 
        :confirm => "Você tem certeza que quer deixar essa rede?")
    else 
       case @school.subscription_type 
        
        when 1 # anyone can join
        link_to "Participar", join_school_path
      when 2 # moderated
        if membership.status == 'pending'
          "(em moderação)"
        else
          link_to "Participar", join_school_path
        end
         
        when 3 #key
        link_to "Participar", "#", {:onclick => "toggleAssociateBox();false;"} 
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
    school.teachers[0..12]
#    sql = "SELECT u.login, u.login_slug FROM users u " \
#          "INNER JOIN user_school_associations a " \
#          "ON u.id = a.user_id " \
#          "AND a.role_id = #{Role[:teacher].id} " \
#          "WHERE a.school_id = #{school.id} LIMIT #{size or 12} "
#          
#    User.find_by_sql(sql)
  end
  
  def waiting_bulletins_count
    Bulletin.count(:conditions => ["school_id = ? AND state LIKE ?", @school.id, "waiting"])
  end
  
  def waiting_events_count
    Event.count(:conditions => ["school_id = ? AND state LIKE ?", @school.id, "waiting"])
  end
  
end
