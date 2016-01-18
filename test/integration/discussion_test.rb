require 'test_helper'

class DiscussionTest < ActionDispatch::IntegrationTest
  setup do
    @gg = users(:gg)
    @gg.password = @gg.password_confirmation = 'foobar'
    @gg.save!
    @course = courses(:math101)
  end

  def show_discussion
    login(@gg)
    visit root_path
    within('#main-menu') do
      click_link 'Teach'
    end
    click_link @course.name
    find(".page-header h4:contains('#{@course.name}')")
    within('#content') do
      click_link 'Discussion'
    end
    find('.nav-tabs li.active a:contains("Discussion")')
  end

  def show_new
    show_discussion
    click_link 'New'
  end

  test 'New' do
    show_new
    fill_in_editor 'topic_content', :with => 'Topic one'
    fill_in 'topic_title', :with => 'Topic one'
    click_button 'Create'
    find('.flash-info:contains("Created")')
    assert has_content?('Topic one')
  end

  test 'New invalid' do
    show_new
    fill_in_editor 'topic_content', :with => ''
    click_button 'Create'
    find('.flash-error:contains("Create failed")')
    find('.modal-body #topic_content ~ span:contains("is required")')
  end

  test 'update' do
    topic = @course.topics.top.last
    show_discussion
    click_link topic.title
    click_link "edit_#{topic.id}"
    fill_in_editor 'topic_content', :with => 'foofighters'
    fill_in 'topic_title', :with => 'updated topic'
    click_button 'Update'
    assert has_content?('foofighters')
    click_link "edit_#{topic.id}"
    fill_in_editor 'topic_content', :with => ''
    click_button 'Update'
    find('.flash-error:contains("Update failed")')
    assert has_content?('foofighters')
  end

  test 'pagination' do
    login(@gg)
    course = courses(:math101)
    Topic.per_page = 1
    visit root_path
    within('#main-menu') do
      click_link 'Teach'
    end
    click_link course.name
    find(".page-header h4:contains('#{course.name}')")
    within('.nav-tabs') do
      click_link 'Discussion'
    end
    find('.nav-tabs li.active a:contains("Discussion")')
    assert has_content?(topics(:two).content)
    assert has_no_content?(topics(:one).content)
    click_link "\u2192"
    assert has_content?(topics(:one).content)
    assert has_no_content?(topics(:two).content)
    Topic.per_page = 10
  end

  test 'delete topic' do
    login(@gg)
    course = courses(:eng101)
    topic = course.topics.last
    visit root_path
    within('#main-menu') do
      click_link 'Home'
    end
    within('#courses') do
      click_link course.name
    end
    find(".page-header h4:contains('#{course.name}')")
    within('.nav-tabs') do
      click_link 'Discussion'
    end
    find('.nav-tabs li.active a:contains("Discussion")')
    assert has_content?(topic.title)
    click_link topic.title
    click_link "Delete"
    accept_dialog
    find('.flash-info:contains("Deleted")')
    assert has_no_content?(topic.content)
  end

  test 'edit topic' do
    login(@gg)
    course = courses(:math101)
    topic = topics(:one)
    visit root_path
    within('#main-menu') do
      click_link 'Teach'
    end
    click_link course.name
    find(".page-header h4:contains('#{course.name}')")
    within('.nav-tabs') do
      click_link 'Discussion'
    end
    find('.nav-tabs li.active a:contains("Discussion")')
    assert has_content?(topic.title)
    click_link topic.title
    click_link "edit_#{topic.id}"
    fill_in_editor 'topic_content', :with => 'New content'
    fill_in 'topic_title', :with => 'New content'
    click_button 'Update'
    assert has_content?('New content')
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
      click_link 'Discussion'
    end
    find('.nav-tabs li.active a:contains("Discussion")')
    assert has_content?(topics(:one).content)
    assert has_content?(topics(:two).content)
    fill_in 'q_content_cont', :with => 'topic two'
    find('#search-form a.search').click
    assert has_no_content?(topics(:one).content)
    assert has_content?(topics(:two).content)
  end

  test 'list replies' do
    login(@gg)
    course = courses(:math101)
    visit root_path
    within('#main-menu') do
      click_link 'Teach'
    end
    click_link course.name
    find(".page-header h4:contains('#{course.name}')")
    within('#content') do
      click_link 'Discussion'
    end
    find('.nav-tabs li.active a:contains("Discussion")')
    click_link topics(:one).title
    find(".table td:contains('#{topics(:one_one).content}')")
    find(".table td:contains('#{topics(:one_two).content}')")
  end

  test 'create reply' do
    login(@gg)
    topic = topics(:one)
    course = topic.course
    visit root_path
    within('#main-menu') do
      click_link 'Teach'
    end
    click_link course.name
    find(".page-header h4:contains('#{course.name}')")
    within('#content') do
      click_link 'Discussion'
    end
    find('.nav-tabs li.active a:contains("Discussion")')
    click_link topics(:one).title
    click_link "reply_#{topic.id}"
    fill_in_editor 'topic_content', :with => 'Sub topic one'
    click_button 'Reply'
    find('.flash-info:contains("Created")')
    find(".table td:contains('#{topic.content}')")
    find('.table td:contains("Sub topic one")')
  end

  test 'edit reply' do
    login(@gg)
    topic = topics(:one)
    subtopic = topic.children.first
    course = topic.course
    visit root_path
    within('#main-menu') do
      click_link 'Teach'
    end
    click_link course.name
    find(".page-header h4:contains('#{course.name}')")
    within('#content') do
      click_link 'Discussion'
    end
    find('.nav-tabs li.active a:contains("Discussion")')
    click_link topics(:one).title
    click_link "edit_#{subtopic.id}"
    fill_in_editor 'topic_content', :with => 'Edited'
    click_button 'Update'
    find('.table td:contains("Edited")')
  end

  test 'category discussion' do
    login(@gg)
    course = courses(:math101)
    visit root_path
    within('#main-menu') do
      click_link 'Teach'
    end
    click_link course.name
    find(".page-header h4:contains('#{course.name}')")
    within('#content') do
      click_link 'Discussion'
    end
    find('.nav-tabs li.active a:contains("Discussion")')
    click_link 'All'
    assert has_content?(topics(:one).title)
    click_link 'Zoology'
    assert has_no_content?(topics(:one).title)
  end
end
