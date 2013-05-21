# -*- encoding : utf-8 -*-
class PaginationListLinkRenderer < WillPaginate::LinkRenderer

  def to_html
    links = @options[:page_links] ? windowed_links : []

    links.unshift(page_link_or_span(@collection.previous_page, 'nav', @options[:previous_label]))
    links.push(page_link_or_span(@collection.next_page, 'nav', @options[:next_label]))

    html = links.join(@options[:separator])
    @options[:container] ? @template.content_tag(:ul, html, html_attributes) : html
  end

protected

  def windowed_links
    visible_page_numbers.map { |n| page_link_or_span(n, (n == current_page ? 'current' : 'number')) }
  end

  def page_link_or_span(page, span_class, text = nil)
    text ||= page.to_s
    if page && page != current_page
      page_link(page, text, :class => span_class)
    else
      page_span(page, text, :class => span_class)
    end
  end

  def page_link(page, text, attributes = {})
    @template.content_tag(:li, @template.link_to(text, url_for(page), attributes))
  end

  def page_span(page, text, attributes = {})
    @template.content_tag(:li, text, attributes)
  end

end
