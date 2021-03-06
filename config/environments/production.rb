Akshi::Application.configure do
  config.cache_classes = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.serve_static_assets = false
  config.assets.compress = true
  config.assets.compile = false
  config.assets.digest = true
  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.action_mailer.default_url_options = {
    :host => 'akshi.com'
  }

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :address              => 'smtp.gmail.com',
    :port                 => 587,
    :domain               => 'akshi.com',
    :user_name            => 'admin@akshi.com',
    :password             => 'RockTheWorld09',
    :authentication       => 'plain',
    :enable_starttls_auto => true
  }

end
