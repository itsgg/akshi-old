require 'simplecov'
SimpleCov.start do
  add_group 'models', 'app/models'
  add_group 'controllers', 'app/controllers'
  add_group 'helpers', 'app/helpers'
  add_group 'workers', 'app/workers'
  add_group 'mailers', 'app/mailers'
  add_group 'views', 'app/views'
  merge_timeout 3600
end

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara/rails'

module Wysihtml5Helper
  def fill_in_editor id, options
    # Wait for the editor component to initialize
    sleep 2
    script = %{EDITORS['#{id}-editor'].setValue(#{options[:with].to_json})}
    page.execute_script script
  end
end

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for
  # all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures
  # explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  def random_string(length=10)
    rand(36 ** length).to_s(36)
  end

  def login(user)
    session[:current_user] = user.id
  end

  def upload(filename='test.pdf')
    File.new(File.join(Rails.root, "/test/fixtures/uploads/#{filename}"))
  end

  def assert_login_required
    assert_equal 'Login to continue', flash[:error]
    assert_template 'sessions/new'
  end

  def assert_unauthorized
    assert_response :unauthorized
  end
end

DatabaseCleaner.strategy = :truncation

class ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Capybara::Email::DSL
  include Wysihtml5Helper

  self.use_transactional_fixtures = false

  setup do
    Capybara.register_driver :chrome do |app|
      Capybara::Selenium::Driver.new(app, :browser => :chrome)
    end
    Capybara.register_driver :firefox do |app|
      Capybara::Selenium::Driver.new(app, :browser => :firefox)
    end
    Capybara.default_driver = :chrome
    # Capybara.default_driver = :firefox
    Capybara.default_wait_time = 10
  end

  teardown do
    DatabaseCleaner.clean
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end

  def login(user)
    visit root_path
    within('#main-menu') do
      click_link 'Login'
    end
    find('.modal-header h4:contains("Login")')
    fill_in 'Username', :with => user.username
    fill_in 'Password', :with => user.password
    within('.modal-footer') do
      click_button 'Login'
    end
    assert_equal 'Logged in', find(:css, 'div.flash-info').text
    find("#main-menu a:contains('#{user.username}')")
    find('#main-menu a:contains("Logout")')
  end

  def accept_dialog
    page.driver.browser.switch_to.alert.accept
  end

  def assert_not_contain(&block)
    begin
      block.call
    end
  end
end

def assert_array_equal(one, two, field)
  (one.map(&field) - two.map(&field)).blank?
end
