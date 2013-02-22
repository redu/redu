module UserProfileNavigation
  def user_profile_navigation(sidebar)
    sidebar.dom_class = 'local-nav'
    sidebar.item :user, "#{@user.display_name}", user_path(@user),
      :link => { :class => 'icon-profile_16_18-before' }
    sidebar.item :wall, 'Mural', show_mural_user_path(@user),
      :link => { :class => 'icon-wall_16_18-before' }
    sidebar.item :members, "Contatos: #{@user.friends.count}",
      user_friendships_path(@user, :profile => true), :class => 'big-separator',
      :link => { :class => 'icon-contacts_16_18-before' }
  end
end
