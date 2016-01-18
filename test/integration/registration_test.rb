require 'test_helper'

class RegistrationTest < ActionDispatch::IntegrationTest
  test 'valid registration' do
    visit root_path
    within('#main-menu') do
      click_link 'Register'
    end
    find('.modal-header h4:contains("Register")')
    fill_in 'Username', :with => 'foobar'
    fill_in 'Fullname', :with => 'Foo Bar'
    fill_in 'Email', :with => 'foobar@akshi.com'
    fill_in 'Password', :with => 'password'
    fill_in 'Repeat password', :with => 'password'
    within('.modal-footer') do
      click_button 'Register'
    end
    find('.flash-info:contains("Registered")')
    find('#main-menu a:contains("foobar")')
    find('#main-menu a:contains("Logout")')
  end

  test 'invalid registration' do
    visit root_path
    within('#main-menu') do
      click_link 'Register'
    end
    find('.modal-header h4:contains("Register")')
    fill_in 'Password', :with => 'password'
    within('.modal-footer') do
      click_button 'Register'
    end
    find('.flash-error:contains("Registration failed")')
    find('#user_username + span:contains("is required")')
    find('#user_fullname + span:contains("is required")')
    find('#user_email + span:contains("is required")')
    find('#user_password_confirmation + span:contains("is required")')
  end
end
