# -*- encoding : utf-8 -*-
module UserProfileNavigation
  def user_profile_navigation(sidebar)
    sidebar.dom_class = 'nav-local'
    sidebar.selected_class = 'nav-local-item-active icon-arrow-right-nav-local-lightblue_11_32-after'

    sidebar.item :user, "#{@user.display_name}", user_path(@user),
      class: 'icon-profile_16_18-before nav-local-item',
      link: { class: 'nav-local-link text-truncate', title: @user.display_name }
    sidebar.item :wall, 'Mural', show_mural_user_path(@user),
      class: 'icon-wall_16_18-before nav-local-item',
      link: { class: 'nav-local-link' }
    sidebar.item :members, "Contatos: #{@user.friends.count}",
      user_friendships_path(@user, profile: true, page: params[:page]),
      class: 'icon-contacts_16_18-before nav-local-item',
      link: { class: 'nav-local-link' }
  end
end
