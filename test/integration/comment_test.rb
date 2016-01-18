require 'test_helper'

class PostsTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @admin.password = @admin.password_confirmation = 'foobar'
    @admin.save!
    @gg = users(:gg)
    @gg.password = @gg.password_confirmation = 'foobar'
    @gg.save!
    @post = @admin.posts.first
    @comment = @post.comments.first
  end

  test 'comment as logged in user' do
    login(@gg)
    visit root_path
    within('#footer') do
      click_link 'Blog'
    end
    click_link "post_#{@post.id}"
    click_link 'Comment'
    find('.modal-header h4:contains("New comment")')
    fill_in_editor 'comment_content', :with => 'Test comment content'
    click_button 'Create'
    find('.flash-info:contains("Comment is under review")')
  end

  test 'comment with invalid attributes' do
    visit root_path
    within('#footer') do
      click_link 'Blog'
    end
    click_link "post_#{@post.id}"
    click_link 'Comment'
    find('.modal-header h4:contains("New comment")')
    click_button 'Create'
    find('.flash-error:contains("Create failed")')
    find('#comment_email ~ span:contains("is required")')
    find('#comment_content ~ span:contains("is required")')
  end

  test 'approve comment' do
    login(@gg)
    within('#footer') do
      click_link 'Blog'
    end
    click_link "post_#{@post.id}"
    click_link 'Comment'
    find('.modal-header h4:contains("New comment")')
    fill_in_editor 'comment_content', :with => 'Test comment content'
    click_button 'Create'
    find('.flash-info:contains("Comment is under review")')
    within('#main-menu') do
      click_link 'Logout'
    end
    find('.flash-info:contains("Logged out")')
    login(@admin)
    visit root_path
    within('#main-menu') do
      click_link 'Admin'
    end
    click_link 'Comments'
    comment = @post.comments.review.last
    click_link "approve_#{comment.id}"
    accept_dialog
    find('.flash-info:contains("Approved")')
    within('#main-menu') do
      click_link 'Logout'
    end
    find('.flash-info:contains("Logged out")')
    login(@gg)
    within('#footer') do
      click_link 'Blog'
    end
    click_link "post_#{@post.id}"
    assert has_content?(comment.content)
  end

  test 'reject comment' do
    login(@gg)
    within('#footer') do
      click_link 'Blog'
    end
    click_link "post_#{@post.id}"
    click_link 'Comment'
    find('.modal-header h4:contains("New comment")')
    fill_in_editor 'comment_content', :with => 'Test comment content'
    click_button 'Create'
    find('.flash-info:contains("Comment is under review")')
    within('#main-menu') do
      click_link 'Logout'
    end
    find('.flash-info:contains("Logged out")')
    login(@admin)
    visit root_path
    within('#main-menu') do
      click_link 'Admin'
    end
    click_link 'Comments'
    comment = @post.comments.review.last
    click_link "reject_#{comment.id}"
    accept_dialog
    find('.flash-info:contains("Rejected")')
    within('#main-menu') do
      click_link 'Logout'
    end
    login(@gg)
    within('#footer') do
      click_link 'Blog'
    end
    click_link "post_#{@post.id}"
    assert has_no_content?(comment.content)
  end
end
