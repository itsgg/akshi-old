require 'test_helper'

class LessonTest < ActionDispatch::IntegrationTest
  setup do
    @gg = users(:gg)
    @gg.password = @gg.password_confirmation = 'foobar'
    @gg.save!
  end

  def show_new
    login(@gg)
    course = @gg.teaching_courses.last
    visit root_path
    within('#main-menu') do
      click_link 'Teach'
    end
    click_link course.name
    find(".page-header h4:contains('#{course.name}')")
    within('#content') do
      click_link 'Lessons'
    end
    find('.nav-tabs li.active a:contains("Lessons")')
    click_link 'New'
  end

  test 'New' do
    show_new
    within('.modal-body') do
      fill_in 'Name', :with => 'Lesson one'
    end
    click_button 'Create'
    find('.flash-info:contains("Created")')
    assert has_content?('Lesson one')
  end

  test 'New invalid' do
    show_new
    within('.modal-body') do
      fill_in 'Name', :with => ''
    end
    click_button 'Create'
    find('.flash-error:contains("Create failed")')
    find('#lesson_name + span:contains("is required")')
  end

  test 'delete' do
    show_new
    within('.modal-body') do
      fill_in 'Name', :with => 'Lesson one'
    end
    click_button 'Create'
    find('.flash-info:contains("Created")')
    assert has_content?('Lesson one')
    click_link 'delete_lesson'
    accept_dialog
    find('.flash-info:contains("Deleted")')
    assert has_no_content?('Lesson one')
  end

  test 'update' do
    lesson_name = 'Lesson one'
    show_new
    within('.modal-body') do
      fill_in :lesson_name, :with => lesson_name
    end
    click_button 'Create'
    find('.flash-info:contains("Created")')
    assert has_content?(lesson_name)
    find(".tabs-left li.active a:contains('#{lesson_name}')")
    within('#lessons') do
      fill_in 'Name', :with => 'Hello world'
      click_button 'Update'
    end
    find('.flash-info:contains("Updated")')
    within('#lessons') do
      fill_in 'Name', :with => ''
      click_button 'Update'
    end
    find('.flash-error:contains("Update failed")')
  end

  test 'search' do
    login(@gg)
    course = courses(:math101)
    visit root_path
    within('#main-menu') do
      click_link 'Teach'
    end
    click_link course.name
    find(".page-header h4:contains('#{course.name}')")
    within('#content') do
      click_link 'Lessons'
    end
    find('.nav-tabs li.active a:contains("Lessons")')
    assert has_content?(lessons(:calculus).name)
    assert has_content?(lessons(:statistics).name)
    fill_in 'q_name_cont', :with => 'statistics'
    find('#search-form a.search').click
    assert has_content?(lessons(:statistics).name)
    assert has_no_content?(lessons(:calculus).name)
  end

  test 'pagination' do
    login(@gg)
    course = courses(:math101)
    Lesson.per_page = 1
    visit root_path
    within('#main-menu') do
      click_link 'Teach'
    end
    click_link course.name
    find(".page-header h4:contains('#{course.name}')")
    within('#content') do
      click_link 'Lessons'
    end
    find('.nav-tabs li.active a:contains("Lessons")')
    assert has_content?(lessons(:calculus).name)
    assert has_no_content?(lessons(:statistics).name)
    click_link "\u2192"
    assert has_content?(lessons(:statistics).name)
    assert has_no_content?(lessons(:calculus).name)
    Lesson.per_page = 10
  end

  test 'filter' do
    login(@gg)
    course = courses(:math101)
    visit root_path
    within('#main-menu') do
      click_link 'Teach'
    end
    click_link course.name
    find(".page-header h4:contains('#{course.name}')")
    within('#content') do
      click_link 'Lessons'
    end
    select 'Media', :from => 'lesson_filter'
    find('.alert:contains("No lessons found")')
    select 'All', :from => 'lesson_filter'
    assert has_content?(lessons(:statistics).name)
  end
  
  test 'category lesson' do
    login(@gg)
    course = courses(:math101)
    visit root_path
    within('#main-menu') do
      click_link 'Teach'
    end
    click_link course.name
    find(".page-header h4:contains('#{course.name}')")
    within('#content') do
      click_link 'Lessons'
    end
    find('.nav-tabs li.active a:contains("Lessons")')
    click_link 'All'
    assert has_content?(lessons(:calculus).name)
    click_link 'Zoology'
    assert has_no_content?(lessons(:calculus).name)
  end
end
