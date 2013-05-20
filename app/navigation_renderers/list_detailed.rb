# -*- encoding : utf-8 -*-
# O Renderer List com a possibilidade de adicionar detalhes em cada <li>
class ListDetailed < SimpleNavigation::Renderer::Base

  def render(item_container)
    list_content = item_container.items.inject([]) do |list, item|
      li_options = item.html_options.reject {|k, v| k == :link}
      li_content = link_to(item.name, item.url, link_options_for(item))
      details_options = item.html_options[:details]
      # Details
      if details_options
        conditions = details_options[:if]
        if conditions.nil? or details_options.delete(:if).call
          li_content << content_tag(:span, details_options.delete(:text),
                                    details_options)
        end
      end
      if include_sub_navigation?(item)
        li_content << render_sub_navigation_for(item)
      end
      list << content_tag(:li, li_content, li_options)
    end.join
    if skip_if_empty? && item_container.empty?
      ''
    else
      content_tag(:ul, list_content, {:id => item_container.dom_id, :class => item_container.dom_class})
    end
  end

  protected

  # Extracts the options relevant for the generated link
  #
  def link_options_for(item)
    special_options = {:method => item.method, :class => item.selected_class}.reject {|k, v| v.nil? }
    link_options = item.html_options[:link]
    return special_options unless link_options
    opts = special_options.merge(link_options)
    opts[:class] = [link_options[:class], item.selected_class].flatten.compact.join(' ')
    opts.delete(:class) if opts[:class].nil? || opts[:class] == ''
    opts
  end


end
