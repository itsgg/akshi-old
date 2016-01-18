require 'test_helper'

class LiveTest < ActionDispatch::IntegrationTest
  setup do
    @gg = users(:gg)
    @gg.password = @gg.password_confirmation = 'foobar'
    @gg.save!
    @akshi = users(:akshi)
    @akshi.password = @akshi.password_confirmation = 'foobar'
    @akshi.save!
    @course = @gg.teaching_courses.last
  end

  test 'chat' do
    login(@gg)
    visit root_path
    within('#main-menu') do
      click_link 'Teach'
    end
    click_link @course.name
    find(".page-header h4:contains('#{@course.name}')")
    within('#content') do
      click_link 'Live'
    end
    find('.nav-tabs li.active a:contains("Live")')
    fill_in 'chat_content', :with => 'Hello from GG'
    click_button 'post-chat'
    assert has_content?('Hello from GG')
  end

  test 'schedule' do
    login(@gg)
    visit root_path
    course = courses(:eng101)
    within('#main-menu') do
      click_link 'Teach'
    end
    click_link course.name
    find(".page-header h4:contains('#{course.name}')")
    within('#content') do
      click_link 'Live'
    end
    find('.nav-tabs li.active a:contains("Live")')
    click_link 'Upcoming classes (1)'
    fill_in 'schedule_description', :with => 'Test class'
    fill_in 'schedule_start_time', :with => 'tomorrow'
    click_button 'Schedule'
    find('.flash-info:contains("Scheduled")')
    assert has_content?('Test class')
    within('.modal') do
      click_button 'Close'
    end
    assert has_content?('Upcoming classes (2)')
  end

  test 'recorded schedule' do
    login(@gg)
    visit root_path
    course = courses(:math101)
    course.publish!
    within('#main-menu') do
      click_link 'Teach'
    end
    click_link course.name
    find(".page-header h4:contains('#{course.name}')")
    within('#content') do
      click_link 'Live'
    end
    find('.nav-tabs li.active a:contains("Live")')
    click_link 'Upcoming classes (0)'
    fill_in 'schedule_description', :with => 'Test class'
    fill_in 'schedule_start_time', :with => 'tomorrow'
    select 'RECORDED', :from => 'schedule_mode'
    select  course.lessons.last.name, :from => 'schedule_lesson_id'
    click_button 'Schedule'
    find('.flash-info:contains("Scheduled")')
    assert has_content?('Test class')
    within('.modal') do
      click_button 'Close'
    end
    assert has_content?('Upcoming classes (1)')
    visit root_path
    click_link 'Upcoming classes'
    click_link 'Test class'
    find('.nav-tabs li.active a:contains("Lessons")')
    assert has_content?(course.lessons.last.name)
  end

  test 'live schedule' do
    login(@gg)
    visit root_path
    course = courses(:math101)
    course.publish!
    within('#main-menu') do
      click_link 'Teach'
    end
    click_link course.name
    find(".page-header h4:contains('#{course.name}')")
    within('#content') do
      click_link 'Live'
    end
    find('.nav-tabs li.active a:contains("Live")')
    click_link 'Upcoming classes (0)'
    fill_in 'schedule_description', :with => 'Test class'
    fill_in 'schedule_start_time', :with => 'tomorrow'
    select 'LIVE', :from => 'schedule_mode'
    select  course.lessons.last.name, :from => 'schedule_lesson_id'
    click_button 'Schedule'
    find('.flash-info:contains("Scheduled")')
    assert has_content?('Test class')
    within('.modal') do
      click_button 'Close'
    end
    assert has_content?('Upcoming classes (1)')
    visit root_path
    click_link 'Upcoming classes'
    click_link 'Test class'
    find('.nav-tabs li.active a:contains("Live")')
    assert has_content?('Upcoming classes (1)')
  end

  test 'Next class' do
    course = courses(:eng101)
    course.publish!
    next_class = course.schedules.active.first
    login(@akshi)
    visit root_path
    within('#courses') do
      click_link course.name
    end
    find(".page-header h4:contains('#{course.name}')")
    within('#content') do
      click_link 'Live'
    end
    find('.nav-tabs li.active a:contains("Live")')
    find(".alert:contains('#{next_class.description}, #{next_class.start_time.to_s :human}')")
  end

  test 'live class should open evenafter user deletion with his chatlog presence' do
    user = User.create!(:username => 'foobar', :fullname => 'Foobar', :password => 'password',
                        :password_confirmation => 'password', :email => 'foobar@akshi.com')
    course = courses(:eng101)
    course.add_student(user)
    login(user)
    visit root_path
    within('#main-menu') do
      click_link 'Learn'
    end
    click_link course.name
    find(".page-header h4:contains('#{course.name}')")
    within('#content') do
      click_link 'Live'
    end
    find('.nav-tabs li.active a:contains("Live")')
    fill_in 'chat_content', :with => 'Hello from GG'
    click_button 'post-chat'
    assert has_content?('Hello from GG')
    click_link 'Logout'
    user.delete
    login(@gg)
    visit root_path
    course = courses(:eng101)
    within('#main-menu') do
      click_link 'Teach'
    end
    click_link course.name
    find(".page-header h4:contains('#{course.name}')")
    within('#content') do
      click_link 'Live'
    end
    find('.nav-tabs li.active a:contains("Live")')
  end
end
