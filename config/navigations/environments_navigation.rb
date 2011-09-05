# -*- coding: utf-8 -*-
# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  # Specify the class that will be applied to active navigation items. Defaults to 'selected'
  navigation.selected_class = 'ui-state-active'

  # Item keys are normally added to list items as id.
  # This setting turns that off
  navigation.autogenerate_item_ids = false

  # Define the primary navigation
  navigation.items do |primary|
    primary.dom_class = 'clearfix ui-tabs-nav'
    primary.item :courses, 'Cursos', environment_path(@environment),
      :class => 'ui-state-default'
    primary.item :account, 'Membros', environment_users_path(@environment),
      :class => 'ui-state-default' do |users_nav|
      # Sub abas
      users_nav.dom_class = 'clearfix ui-tabs-nav'
      users_nav.item :all, "Todos", environment_users_path(@environment),
        :highlights_on => Proc.new { !params.has_key? :role },
        :class => 'ui-state-default',
        :link => { :class => 'icon-bio_16_18-before' }
      users_nav.item :teachers, "Professores",
        environment_users_path(@environment, :role => "teachers"),
        :highlights_on => Proc.new { params[:role].eql? "teachers" },
        :class => 'ui-state-default',
        :link => { :class => 'icon-cv_16_18-before' }
      users_nav.item :tutors, "Tutores",
        environment_users_path(@environment, :role => "tutors"),
        :highlights_on => Proc.new { params[:role].eql? "tutors" },
        :class => 'ui-state-default',
        :link => { :class => 'icon-cv_16_18-before' }
      users_nav.item :students, "Alunos",
        environment_users_path(@environment, :role => "students"),
        :highlights_on => Proc.new { params[:role].eql? "students" },
        :class => 'ui-state-default',
        :link => { :class => 'icon-cv_16_18-before' }
      end
  end
end
