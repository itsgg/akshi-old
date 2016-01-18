require 'test_helper'

class AccountTest < ActionDispatch::IntegrationTest
  setup do
    @gg = users(:gg)
    @gg.password = @gg.password_confirmation = 'foobar'
    @gg.save!
  end

  test 'update' do
    login(@gg)
    within('#main-menu') do
      click_link @gg.username
    end
    find(".page-header h4:contains('#{@gg.fullname} - #{@gg.username}')")
    fill_in_editor 'user_about', :with => 'Rocking Rockstar'
    fill_in 'user_email', :with => 'ganeshg@akshi.com'
    fill_in 'user_fullname', :with => 'Ganesh Gunasegaran'
    fill_in 'user_password', :with => 'foobar'
    fill_in 'user_password_confirmation', :with => 'foobar'
    click_button 'Update'
    find('.flash-info:contains("Updated")')
    assert_equal 'Ganesh Gunasegaran', find('#user_fullname').value
    assert_equal 'ganeshg@akshi.com', find('#user_email').value
    assert find('#user_about').value.include?('Rocking Rockstar')
    find('.flash-info:contains("Updated")')
  end

  test 'update invalid attributes' do
    login(@gg)
    within('#main-menu') do
      click_link @gg.username
    end
    find(".page-header h4:contains('#{@gg.fullname} - #{@gg.username}')")
    fill_in 'Email', :with => 'foobar'
    click_button 'Update'
    find('.flash-error:contains("Update failed")')
    find('#user_email + span:contains("is invalid")')
  end

  test 'show user profile' do
    visit root_path
    computer = courses(:comp101)
    user = computer.teachers.last
    within('#courses') do
      click_link computer.name
    end
    find(".page-header h4:contains('#{computer.name}')")
    within('#content') do
      click_link 'Users'
    end
    find('.nav-tabs li.active a:contains("Users")')
    click_link user.fullname
    find(".page-header h4:contains('#{user.fullname} - #{user.username}')")
    assert has_content?(user.about)
    within('#content') do
      click_link 'Learning'
    end
    find('.nav-tabs li.active a:contains("Learning")')
    user.learning_courses.each do |course|
      assert has_content?(course.name)
      assert has_content?("Popular courses")
      assert has_no_content?("Featured courses")
    end
    within('#content') do
      click_link 'Teaching'
    end
    user.teaching_courses.published.each do |course|
      assert has_content?(course.name)
      assert has_content?("Popular courses")
      assert has_no_content?("Featured courses")
    end
  end
end
