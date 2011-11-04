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
    # A navegação de Courses#index não possui sidebar, bloco apenas para
    # manter o padrão
    primary.item :sidebar, 'Sidebar', home_path do |tabs|
      tabs.dom_class = 'clearfix ui-tabs-nav'
      tabs.item :all, 'Todos',
        courses_index_path,
        :highlights_on => Proc.new { !params.has_key? :role },
        :class => 'ui-state-default',
        :link => { :class => 'icon-course_16_18-before' }
      unless Course.user_behave_as_student(current_user).empty?
        tabs.item :student, 'Aluno',
          courses_index_path(:role => 'student'),
          :highlights_on => Proc.new { params[:role] == 'student' },
          :class => 'ui-state-default',
          :link => { :class => 'icon-member_16_18-before' }
      end
      unless Course.user_behave_as_tutor(current_user).empty?
        tabs.item :tutor, 'Tutor',
          courses_index_path(:role => 'tutor'),
          :highlights_on => Proc.new { params[:role] == 'tutor' },
          :class => 'ui-state-default',
          :link => { :class => 'icon-tutor_16_18-before' }
      end
      unless Course.user_behave_as_teacher(current_user).empty?
        tabs.item :teacher, 'Professor',
          courses_index_path(:role => 'teacher'),
          :highlights_on => Proc.new { params[:role] == 'teacher' },
          :class => 'ui-state-default',
          :link => { :class => 'icon-teacher_16_18-before' }
      end
      unless Course.user_behave_as_administrator(current_user).empty?
        tabs.item :administrator, 'Administrador',
          courses_index_path(:role => 'administrator'),
          :highlights_on => Proc.new { params[:role] == 'administrator' },
          :class => 'ui-state-default',
          :link => { :class => 'icon-environment_admin_16_18-before' }
      end
    end
  end
end
