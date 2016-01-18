module ApplicationHelper
  def hash_url(url, path)
    if url.present? && path.present?
      (url.sub(path, '') + "/#!#{path}").gsub('.js', '')
    end
  end

  def home_page?
    params[:controller] == 'courses' && (params[:type].blank? || params[:type] == 'home')
  end

  def teach_page?
    params[:controller] == 'courses' && params[:type] == 'teach'
  end

  def hash_path(path)
    # Convert to hash path
    # Stupid: Remove :format => js
    "#!#{path}".gsub('.js', '')
  end

  def basename(file_path)
    file_path.chomp(File.extname(file_path))
  end

  def strip_html(html)
    html.gsub(/<\/?.*?>/, " ").gsub(/&nbsp;/i, " ") if html.present?
  end

  def timeago(time, options = {})
    options[:class] ||= "timeago"
    content_tag(:abbr, time.to_s, options.merge(:title => time.getutc.iso8601)) if time
  end

  def menu_class(menu_name)
    controller = params[:controller]
    action = params[:action]
    type = params[:type]
    subtype = params[:subtype]
    active = case menu_name
             when 'account'
              controller == 'users' &&
              !(action == 'new' || action == 'create')
             when 'register'
              controller == 'users' &&
              (action == 'new' || action == 'create')
             when 'login'
              controller == 'sessions' &&
              (action == 'new' || action == 'create')
             when 'home'
              controller != 'users' && (type.blank? || type == 'home')
             when 'admin'
              type == menu_name
             when 'learn', 'teach'
              type == menu_name
             when 'details'
              (subtype == menu_name) ||
              (subtype.blank? && controller == 'courses')
             when 'users'
              subtype == menu_name && controller == 'courses'
             when 'discussion'
              subtype == menu_name && controller == 'topics'
             when 'lessons'
              subtype == menu_name && controller == 'lessons'
             when 'subjects'
              subtype == menu_name && controller == 'subjects'
             when 'announcements'
              subtype == menu_name && controller == 'announcements'
             when 'quizzes'
              subtype == menu_name && ['quizzes', 'questions'].include?(controller)
             when 'live'
              subtype == menu_name && ['lives', 'schedules'].include?(controller)
             when 'profile'
              (subtype == menu_name) || (subtype.blank? && controller == 'users')
             when 'teaching', 'learning'
              subtype == menu_name && controller == 'users'
             when 'admin_courses', 'admin_comments', 'admin_categories',
                  'admin_collections', 'admin_users'
              subtype == menu_name
             when 'available'
              params[:voucher_type].blank? ||
              params[:voucher_type] == menu_name &&
              controller == 'vouchers'
             when 'used'
              params[:voucher_type] == menu_name &&
              controller == 'vouchers'
             end
    'active' if active
  end

  def menu_link(type='browse', params={})
    menu_name = t("main_menu.#{type}")
    link_to menu_name, hash_path(courses_path({:type => type, :q => params[:q],
                                  :category => params[:category],
                                  :viewas => params[:viewas],
                                  :collection => params[:collection]
                                }))
  end

  def children_ids(root)
    output = root.subtree_ids
    output.delete(root.id)
    output
  end

  def country_select(input_name)
    countries_list = {
                      :IND => 'India',
                      :split => 'true',
                      :USA => 'United States',
                      :AUS => 'Australia',
                      :ARE => 'United Arab Emirates',
                      :SGP => 'Singapore'
                     }
    content_tag(:select, :id => input_name, :name => input_name, :class => 'rich') do
      countries_list.map do |country_key, country_name|
        if country_key == :split
          concat(content_tag(:option, '------------------------------',
                             :disabled => true))
        else
          concat(content_tag(:option, country_name, :value => country_key))
        end
      end
    end
  end

  def grouped_subject(course)
    grouped_options = course.document_lessons.inject({}) do |options, course|
      unless course.subject.blank?
        (options[course.subject.name] ||= []) << [course.upload_file_name, course.id]
      else
        (options["All"] ||= []) << [course.upload_file_name, course.id]
      end
      options
    end
    grouped_options
  end
end
