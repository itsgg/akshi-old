require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'digest/md5'
require 'chronic'

if defined?(Bundler)
  Bundler.require(*Rails.groups(:assets => %w(development test)))
end

module Akshi
  class Application < Rails::Application
    config.encoding = "utf-8"
    config.filter_parameters += [:password]
    config.active_support.escape_html_entities_in_json = true
    config.active_record.whitelist_attributes = true
    config.assets.enabled = true
    config.assets.version = '1.0'
    config.assets.paths << Rails.root.join('app', 'assets', 'flash')
    config.assets.paths << Rails.root.join('vendor', 'assets', 'flash')
    config.assets.paths << Rails.root.join('vendor', 'assets', 'images')
    config.generators.stylesheets = false
    config.generators.javascripts = false
    config.active_record.observers = :announcement_observer, :topic_observer, :course_observer, :comment_observer
    config.action_view.field_error_proc = proc {|html, instance| html}
    config.middleware.swap Rack::MethodOverride, Rack::MethodOverrideWithParams
    config.time_zone = 'Chennai'
  end
end

class Setting < Settingslogic
  source "#{Rails.root}/config/application.yml"
  namespace Rails.env
end
