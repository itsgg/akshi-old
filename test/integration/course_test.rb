require 'test_helper'

class CourseTest < ActionDispatch::IntegrationTest
  setup do
    @gg = users(:gg)
    @gg.password = @gg.password_confirmation = 'foobar'
    @gg.save!
    @admin = users(:admin)
    @admin.password = @admin.password_confirmation = 'foobar'
    @admin.save!
    @akshi = users(:akshi)
    @akshi.password = @akshi.password_confirmation = 'foobar'
    @akshi.save!
    @course = @gg.teaching_courses.published.last
  end

  def course_update_status
    login(@gg)
    within('#main-menu') do
      click_link 'Teach'
    end
    find('#main-menu li.active:contains("Teach")')
    within('#courses') do
      click_link 'Mathematics 101'
    end
    find('.page-header h4:contains("Mathematics 101")')
    check 'course_published'
    click_button 'Update'
    find('.flash-info:contains("Updated")')
    find('.alert:contains("Course is under review")')
    within('#main-menu') do
      click_link 'Logout'
    end
    find('.flash-info:contains("Logged out")')
  end

  def course_publish
    login(@gg)
    within('#main-menu') do
      click_link 'Teach'
    end
    find('#main-menu li.active:contains("Teach")')
    within('#content') do
      click_link 'New'
    end
    fill_in 'Name', :with => 'Test course'
    click_button 'Create'
    find('.flash-info:contains("Created")')
    find('.page-header h4:contains("Test course")')
    within('#main-menu') do
      click_link 'Home'
    end
    assert has_no_content?('Test course')
    within('#main-menu') do
      click_link 'Teach'
    end
    find('#main-menu li.active:contains("Teach")')
    click_link 'Test course'
    find(".page-header h4:contains('Test course')")
    check 'course_published'
    click_button 'Update'
    find('.flash-info:contains("Updated")')
  end

  test 'toggle view' do
    visit root_path
    assert find(:css, 'i.icon-th-list.icon-gray')
    within('#courses') do
      assert find(:css, '.thumbnails')
    end
    click_link('viewas-list')
    assert find(:css, 'i.icon-th.icon-gray')
    within('#courses') do
      assert find(:css, 'table')
    end
  end

  test 'pagination' do
    visit root_path(:per_page => 1)
    within('#courses') do
      assert has_content?(courses(:eng101).name)
      assert has_no_content?(courses(:comp101).name)
    end
    click_link "\u2192"
    within('#courses') do
      assert has_content?(courses(:comp101).name)
      assert has_no_content?(courses(:eng101).name)
    end
    100.times do
      Course.create!(:name => 'hello', :status => "published",
                     :description => random_string(50),
                     :category_id => Category.first.id)
    end
    visit root_path(:per_page => 1)
    assert has_css?('.gap')
  end

  test 'search' do
    visit root_path
    fill_in 'q_name_or_description_cont', :with => 'English'
    find('#search-form a.search').click
    within('#courses') do
      assert has_content?(courses(:eng101).name)
      assert has_no_content?(courses(:math101).name)
      assert has_no_content?(courses(:comp101).name)
    end
  end

  test 'category' do
    visit root_path
    select 'Computer', :from => 'category'
    within('#courses') do
      assert has_content?(courses(:comp101).name)
      assert has_content?(courses(:ruby101).name)
      assert has_no_content?(courses(:math101).name)
      assert has_no_content?(courses(:eng101).name)
    end
  end

  test 'learn without login' do
    visit root_path
    within('#main-menu') do
      click_link 'Learn'
    end
    find('.modal-header h4:contains("Login")')
  end

  test 'teach without login' do
    visit root_path
    within('#main-menu') do
      click_link 'Teach'
    end
    find('.modal-header h4:contains("Login")')
  end

  test 'learn' do
    login(@gg)
    visit root_path
    within('#main-menu') do
      click_link 'Learn'
    end
    find('#main-menu li.active:contains("Learn")')
    @gg.learning_courses.each do |course|
      assert has_content?(course.name)
    end
    (Course.all - @gg.learning_courses).each do |course|
      assert has_no_content?(course.name)
    end
  end

  test 'teach' do
    login(@gg)
    visit root_path
    within('#main-menu') do
      click_link 'Teach'
    end
    find('#main-menu li.active:contains("Teach")')
    @gg.teaching_courses.each do |course|
      assert has_content?(course.name)
    end
    (Course.all - @gg.teaching_courses).each do |course|
      assert has_no_content?(course.name)
    end
  end

  test 'course creation valid attributes' do
    login(@gg)
    within('#main-menu') do
      click_link 'Teach'
    end
    find('#main-menu li.active:contains("Teach")')
    within('#content') do
      click_link 'New'
    end
    find('.modal-header h4:contains("New")')
    fill_in 'Name', :with => 'Test course'
    click_button 'Create'
    find('.flash-info:contains("Created")')
    find('.page-header h4:contains("Test course")')
    within('#main-menu') do
      click_link 'Home'
    end
    assert has_no_content?('Test course')
    within('#main-menu') do
      click_link 'Teach'
    end
    assert has_content?('Test course')
  end

  test 'course publish' do
    course_publish
  end

  test 'course creation invalid attributes' do
    login(@gg)
    within('#main-menu') do
      click_link 'Teach'
    end
    find('#main-menu li.active:contains("Teach")')
    within('#content') do
      click_link 'New'
    end
    find('.modal-header h4:contains("New")')
    click_button 'Create'
    find('.flash-error:contains("Create failed")')
    find('#course_name ~ span:contains("is required")')
  end

  test 'course deletion' do
    login(@gg)
    within('#main-menu') do
      click_link 'Teach'
    end
    find('#main-menu li.active:contains("Teach")')
    click_link @course.name
    find(".page-header h4:contains('#{@course.name}')")
    click_link 'delete_course'
    accept_dialog
    find('.flash-info:contains("Deleted")')
    within('#main-menu') do
      click_link 'Teach'
    end
    find('#main-menu li.active:contains("Teach")')
    assert has_no_content?(@course.name)
  end

  test 'course update' do
    login(@gg)
    within('#main-menu') do
      click_link 'Teach'
    end
    find('#main-menu li.active:contains("Teach")')
    click_link @course.name
    find(".page-header h4:contains('#{@course.name}')")
    fill_in 'Name', :with => 'Foobar'
    click_button 'Update'
    find('.flash-info:contains("Updated")')
    within('#main-menu') do
      click_link 'Teach'
    end
    find('#main-menu li.active:contains("Teach")')
    assert has_content?('Foobar')
  end

  test 'course update feature enable' do
    Capybara.default_wait_time = 1

    login(@gg)
    within('#main-menu') do
      click_link 'Teach'
    end
    find('#main-menu li.active:contains("Teach")')
    click_link @course.name
    find(".page-header h4:contains('#{@course.name}')")
    check 'Announcement'
    uncheck 'Lesson'
    uncheck 'Discussion'
    check 'Quiz'
    uncheck 'Live'
    click_button 'Update'
    find('.flash-info:contains("Updated")')
    find('#main-menu li.active:contains("Teach")')
    find('#content .nav-tabs li a:contains("Announcements")')
    find('#content .nav-tabs li a:contains("Quizzes")')
    assert_raise Capybara::ElementNotFound do
      find('#content .nav-tabs li a:contains("Lessons")')
    end
    assert_raise Capybara::ElementNotFound do
      find('#content .nav-tabs li a:contains("Lives")')
    end
    assert_raise Capybara::ElementNotFound do
      find('#content .nav-tabs li a:contains("Discussion")')
    end
  end

  test 'course update invalid attributes' do
    login(@gg)
    within('#main-menu') do
      click_link 'Teach'
    end
    find('#main-menu li.active:contains("Teach")')
    click_link @course.name
    find(".page-header h4:contains('#{@course.name}')")
    fill_in 'Name', :with => ''
    click_button 'Update'
    find('.flash-error:contains("Update failed")')
    find('#course_name ~ span:contains("is required")')
  end

  test 'details' do
    visit root_path
    within('#courses') do
      click_link @course.name
    end
    find(".page-header h4:contains('#{@course.name}')")
    find('.nav-tabs li.active a:contains("Details")')
    assert has_content?(@course.description)
  end

  test 'lessons' do
    login(@gg)
    visit root_path
    within('#courses') do
      click_link @course.name
    end
    find(".page-header h4:contains('#{@course.name}')")
    within('.nav-tabs') do
      click_link 'Lessons'
    end
    find('.nav-tabs li.active a:contains("Lessons")')
    @course.lessons.each do |lesson|
      assert has_content?(lesson.name)
    end
  end

  test 'announcements' do
    login(@gg)
    visit root_path
    within('#courses') do
      click_link @course.name
    end
    find(".page-header h4:contains('#{@course.name}')")
    within('.nav-tabs') do
      click_link 'Announcements'
    end
    find('.nav-tabs li.active a:contains("Announcements")')
    @course.announcements.each do |announcement|
      assert has_content?(announcement.content)
    end
  end

  test 'discussion' do
    login(@gg)
    visit root_path
    within('#courses') do
      click_link @course.name
    end
    find(".page-header h4:contains('#{@course.name}')")
    within('.nav-tabs') do
      click_link 'Discussion'
    end
    find('.nav-tabs li.active a:contains("Discussion")')
    @course.topics.each do |topic|
      assert has_content?(topic.content)
    end
  end

  test 'live' do
    login(@gg)
    visit root_path
    within('#courses') do
      click_link @course.name
    end
    find(".page-header h4:contains('#{@course.name}')")
    within('.nav-tabs') do
      click_link 'Live'
    end
    find('.nav-tabs li.active a:contains("Live")')
  end

  test 'users' do
    login(@gg)
    visit root_path
    within('#courses') do
      click_link @course.name
    end
    find(".page-header h4:contains('#{@course.name}')")
    within('.nav-tabs') do
      click_link 'Users'
    end
    find('.nav-tabs li.active a:contains("Users")')
    @course.users.each do |user|
      assert has_content?(user.username)
      assert has_content?(user.fullname)
    end
    @course.teachers.each do |teacher|
      assert has_content?(teacher.username)
      assert has_content?(teacher.fullname)
    end
    find('tr td:nth-child(2) span:contains("T")')
  end

  test 'cover errors' do
    @course.errors.add(:cover_file_size, 'test error')
    assert @course.cover_errors?
  end

  test 'filter' do
    visit root_path
    category = categories(:computer)
    select category.name, :from => "category"
    within('#courses') do
      assert has_content?(courses(:comp101).name)
      assert has_no_content?(courses(:eng101).name)
    end
  end

  test 'update status' do
    course_update_status
  end

  test 'approve published courses' do
    course_update_status
    login(@admin)
    within('#main-menu') do
      click_link @admin.username
    end
    within('#main-menu') do
      click_link 'Admin'
    end
    click_link 'Courses'
    click_link "accept_#{courses(:math101).id}"
    accept_dialog
    find('.flash-info:contains("Published")')
    within('#main-menu') do
      click_link 'Logout'
    end
    find('.flash-info:contains("Logged out")')
    login(@gg)
    within('#main-menu') do
      click_link 'Home'
    end
    find('#main-menu li.active:contains("Home")')
    assert has_content?(courses(:math101).name)
    within('#main-menu') do
      click_link 'Teach'
    end
    find('#main-menu li.active:contains("Teach")')
    within('#content') do
      click_link 'Mathematics 101'
    end
    find('.page-header h4:contains("Mathematics 101")')
    assert has_no_content?("Course is under review")
  end

  test 'reject published courses' do
    course_update_status
    login(@admin)
    within('#main-menu') do
      click_link @admin.username
    end
    within('#main-menu') do
      click_link 'Admin'
    end
    click_link 'Courses'
    click_link "reject_#{courses(:math101).id}"
    accept_dialog
    find('.flash-info:contains("Rejected")')
    within('#main-menu') do
      click_link 'Logout'
    end
    find('.flash-info:contains("Logged out")')
    login(@gg)
    within('#main-menu') do
      click_link 'Home'
    end
    find('#main-menu li.active:contains("Home")')
    within('#courses') do
      assert has_no_content?(courses(:math101).name)
    end
    within('#main-menu') do
      click_link 'Teach'
    end
    find('#main-menu li.active:contains("Teach")')
    within('#content') do
      click_link 'Mathematics 101'
    end
    find('.page-header h4:contains("Mathematics 101")')
    find('.alert:contains("Course is rejected")')
  end

  test 'featured course' do
    login(@gg)
    within('#main-menu') do
      click_link 'Teach'
    end
    find('#main-menu li.active:contains("Teach")')
    assert has_content?('Popular course')
    assert has_no_content?('Featured course')
    click_link @course.name
    find(".page-header h4:contains('#{@course.name}')")
    check 'course_featured'
    click_button 'Update'
    find('.flash-info:contains("Updated")')
    within('#main-menu') do
      click_link 'Teach'
    end
    find('#main-menu li.active:contains("Teach")')
    assert has_content?('Popular course')
    assert has_content?('Featured course')
    visit root_path
    assert find(:css, 'i.icon-th-list.icon-gray')
    click_link('viewas-list')
    assert find(:css, 'i.icon-th.icon-gray')
    assert has_content?('Popular course')
    assert has_content?('Featured course')
  end
end
