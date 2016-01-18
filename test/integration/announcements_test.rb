require 'test_helper'

class AnnouncementsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:gg)
    @user.password = @user.password_confirmation = 'foobar'
    @user.save!
    @course = @user.teaching_courses.first
  end

  def create_announcement
    login(@user)
    visit root_path
    within('#courses') do
      click_link @course.name
    end
    within('#content') do
      click_link 'Announcements'
    end
    find('.nav-tabs li.active a:contains("Announcements")')
    click_link 'New'
    fill_in_editor 'announcement_content', :with => 'Test announcement'
    click_button 'Post'
    find('.flash-info:contains("Created")')
    assert has_content?('Test announcement')
  end

  test 'Post announcement' do
    create_announcement
  end

  test 'Delete announcement' do
    create_announcement
    announcement = @course.announcements.last
    click_link "delete_#{announcement.id}"
    accept_dialog
    find('.flash-info:contains("Deleted")')
    assert has_no_content?(announcement.content)
  end

  test 'Update announcement' do
    login(@user)
    visit root_path
    within('#courses') do
      click_link @course.name
    end
    within('#content') do
      click_link 'Announcements'
    end
    find('.nav-tabs li.active a:contains("Announcements")')
    announcement = @course.announcements.last
    click_link "edit_#{announcement.id}"
    fill_in_editor 'announcement_content', :with => 'Test announcement updated'
    click_button 'Update'
    find('.flash-info:contains("Updated")')
    assert has_content?('Test announcement updated')
  end

  test 'category announcement' do
    login(@user)
    visit root_path
    within('#courses') do
      click_link @course.name
    end
    within('#content') do
      click_link 'Announcements'
    end
    click_link 'New'
    fill_in_editor 'announcement_content', :with => 'Test Mathematics announcement'
    click_button 'Post'
    select "Mathematics"
    find('.flash-info:contains("Created")')
    assert has_content?('Test Mathematics announcement')
    find('.nav-tabs li.active a:contains("Announcements")')
    click_link('Mathematics')
    announcement = @course.announcements.last
    assert has_content?("Test Mathematics announcement")
  end
end
