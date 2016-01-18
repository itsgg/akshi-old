require 'test_helper'

class LoginTest < ActionDispatch::IntegrationTest
  setup do
    @gg = users(:gg)
    @gg.password = @gg.password_confirmation = 'foobar'
    @gg.save!
  end

  test 'valid login' do
    login(@gg)
  end

  test 'protected download unauthorized' do
    lesson = lessons(:calculus)
    lesson.upload = upload('test.pdf')
    assert lesson.save
    get lesson.upload.url
    assert_response :unauthorized
  end

  test 'protected download' do
    lesson = lessons(:calculus)
    lesson.upload = upload('test.pdf')
    assert lesson.save
    xhr :post, sessions_path(:username => @gg.username, :password => @gg.password)
    get lesson.upload.url
    assert_response :success
  end

  test 'invalid login' do
    visit root_path
    within('#main-menu') do
      click_link 'Login'
    end
    find('.modal-header h4:contains("Login")')
    within('.modal-footer') do
      click_button 'Login'
    end
    find('.flash-error:contains("Invalid username/password")')
  end

  test 'blocked user' do
    @gg.update_attribute(:blocked, true)
    visit root_path
    within('#main-menu') do
      click_link 'Login'
    end
    find('.modal-header h4:contains("Login")')
    fill_in 'Username', :with => @gg.username
    fill_in 'Password', :with => @gg.password
    within('.modal-footer') do
      click_button 'Login'
    end
    find('.flash-error:contains("User blocked. Contact admin.")')
  end

  test 'logout' do
    login(@gg)
    within('#main-menu') do
      click_link 'Logout'
    end
    find('.flash-info:contains("Logged out")')
    find('#main-menu a:contains("Login")')
  end

  test 'forgot password' do
    visit root_path
    within('#main-menu') do
      click_link 'Login'
    end
    assert has_content?('Forgot password?')
    within('.modal-body') do
      click_link 'Forgot password?'
    end
    find('.modal-header h4:contains("Forgot password")')
    fill_in 'username_email', :with => @gg.username
    click_button 'Recover'
    find('.flash-info:contains("Reset instruction emailed")')
    open_email(@gg.email)
    current_email.has_content?("Hi #{@gg.username}")
    current_email.has_content?(reset_password_user_path(@gg))

  end

  test 'forgot password invalid user' do
    visit root_path
    within('#main-menu') do
      click_link 'Login'
    end
    assert has_content?('Forgot password?')
    within('.modal-body') do
      click_link 'Forgot password?'
    end
    find('.modal-header h4:contains("Forgot password")')
    fill_in 'username_email', :with => 'blahblah'
    click_button 'Recover'
    find('.flash-error:contains("User not found")')
  end
end
