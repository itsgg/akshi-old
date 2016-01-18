module PaginateHelper
  class BootstrapLinkRenderer < ::WillPaginate::ActionView::LinkRenderer
    def url(page)
      "#!#{super}&paginate=true"
    end

    protected
    def html_container(html)
      tag :div, tag(:ul, html), container_attributes
    end

    def page_number(page)
      tag :li, link(page, page, :rel => rel_value(page), :class => 'scroll-top'),
          :class => ('active' if page == current_page)
    end

    def gap
      tag :li, link('..', 'javascript:;'), :class => 'gap disabled'
    end

    def previous_or_next_page(page, text, classname)
      tag :li, link(text, page || 'javascript:;'),
          :class => [classname[0..3], classname,
                    ('disabled' unless page)].join(' ')
    end
  end

  # bootstrap customized pagination links
  def page_navigation_links(pages, options={})
    will_paginate(pages, {:class => 'pagination',
                          :previous_label => '&larr;'.html_safe,
                          :renderer => BootstrapLinkRenderer,
                          :next_label => '&rarr;'.html_safe}.merge(options))
  end
end
