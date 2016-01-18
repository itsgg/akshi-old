require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
 setup do
    @gg = users(:gg)
    @admin = users(:admin)
    @post = posts(:post_one)
    @comment = comments(:first_comment)
  end

  test 'New' do
    xhr :get, :new, :post_id => @post.id
    assert_response :success
    assert assigns(:comment).new_record?
  end

  test 'Create' do
    assert_difference('Comment.count') do
      xhr :post, :create, :post_id => @post,
                 :comment => {:content => 'test comment', :email => 'akshi@akshi.com'}
      assert_response :success
      assert_equal 'test comment', assigns(:comment).content
      assert_equal 'akshi@akshi.com', assigns(:comment).email
    end
  end

  test 'update not logged in' do
    xhr :put, :update_status, :post_id => @post.id,
              :comment_id => @comment.id, :status => 'approve'
    assert_login_required
  end

  test 'update unauthorized' do
    login(@gg)
    xhr :put, :update_status, :post_id => @post.id,
              :comment_id => @comment.id, :status => 'approve'
    assert_unauthorized
  end

  test 'update status' do
    login(@admin)
    xhr :put, :update_status, :post_id => @post.id,
              :comment_id => @comment.id, :status => 'approve'
    assert_response :success
    assert_equal 'approved', assigns(:comment).status
    xhr :put, :update_status, :post_id => @post.id,
              :comment_id => @comment.id, :status => 'reject'
    assert_response :success
    assert_equal 'rejected', assigns(:comment).status
  end
end
