require 'test_helper'

class PostsTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @admin.password = @admin.password_confirmation = 'foobar'
    @admin.save!
    @post = @admin.posts.first
  end

  test 'create post' do
    login(@admin)
    visit root_path
    within('#footer') do
      click_link 'Blog'
    end
    click_link 'New'
    fill_in_editor 'post_content', :with => 'Test post content'
    fill_in 'post_title', :with => 'Test post'
    click_button 'Create'
    find('.flash-info:contains("Created")')
    assert has_content?('Test post content')
  end

  test 'edit post' do
    login(@admin)
    visit root_path
    within('#footer') do
      click_link 'Blog'
    end
    click_link "post_#{@post.id}"
    click_link 'Edit'
    fill_in_editor 'post_content', :with => 'Content edited'
    fill_in 'post_title', :with => 'Test post edited'
    click_button 'Update'
    find('.flash-info:contains("Updated")')
    assert has_content?('Test post edited')
    assert has_content?('Content edited')
  end

  test 'delete post' do
    login(@admin)
    visit root_path
    within('#footer') do
      click_link 'Blog'
    end
    click_link "post_#{@post.id}"
    click_link 'Delete'
    accept_dialog
    find('.flash-info:contains("Deleted")')
    assert has_no_content?(@post.title)
    assert has_no_content?(@post.content)
  end

  test 'create invalid attributes' do
    login(@admin)
    visit root_path
    within('#footer') do
      click_link 'Blog'
    end
    click_link 'New'
    find('.modal-header h4:contains("New")')
    click_button 'Create'
    find('.flash-error:contains("Create failed")')
    find('#post_title ~ span:contains("is required")')
    find('#post_content ~ span:contains("is required")')
  end

  test 'post update invalid attributes' do
    login(@admin)
    visit root_path
    within('#footer') do
      click_link 'Blog'
    end
    click_link "post_#{@post.id}"
    click_link 'Edit'
    find('.modal-header h4:contains("Edit")')
    fill_in_editor 'post_content', :with => ""
    fill_in 'post_title', :with => ""
    click_button 'Update'
    find('.flash-error:contains("Update failed")')
    find('#post_title ~ span:contains("is required")')
    find('#post_content ~ span:contains("is required")')
  end

  test 'pagination' do
    login(@admin)
    visit root_path
    click_link 'Blog'
    assert has_content?('Home')
    assert has_content?('Blog')
    100.times do
      Post.create!(:title => 'hello',
                     :content => random_string(50),
                     :user_id => User.first.id)
    end

    visit root_path
    click_link 'Blog'
    click_link "\u2192"
    assert has_no_content?('Akshi is a social learning platform.')
  end
end
