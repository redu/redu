# -*- encoding : utf-8 -*-
SimpleNavigation.config_file_path = File.join(Rails.root, 'config', 'navigations')
SimpleNavigation.register_renderer :my_renderer => ListDetailed
SimpleNavigation.register_renderer :my_renderer => ListSidebar
SimpleNavigation.register_renderer :my_renderer => NewListSidebar
