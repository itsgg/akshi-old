require 'test_helper'

class PostsControllerTest < ActionController::TestCase
  setup do
    @gg = users(:gg)
    @admin = users(:admin)
    @post = posts(:post_one)
  end

  test 'index' do
    xhr :get, :index
    assert_response :success
    assert_equal Post.count, assigns(:posts).size
  end

  test 'search' do
    xhr :get, :index, :q => {:content_cont => 'Akshi'}
    assert_response :success
    assert_equal [posts(:post_one)], assigns(:posts)
  end

  test 'show' do
    post = posts(:post_one)
    xhr :get, :show, :id => post
    assert_equal post, assigns(:post)
  end

  test 'new not logged in' do
    xhr :get, :new
    assert_login_required
  end

  test 'new unauthorized' do
    login(@gg)
    xhr :get, :new
    assert_unauthorized
  end

  test 'new' do
    login(@admin)
    xhr :get, :new
    assert_response :success
    assert assigns(:post).new_record?
  end

  test 'create not logged in' do
    assert_no_difference('Post.count') do
      xhr :post, :create,
          :post => {:content => 'Test blog 2 content', :title => 'test blog 2'}
      assert_login_required
    end
  end

  test 'create unauthorized' do
    login(@gg)
    assert_no_difference('Post.count') do
      xhr :post, :create,
          :post => {:content => 'Test blog 2 content', :title => 'test blog 2'}
      assert_unauthorized
    end
  end

  test 'create' do
    login(@admin)
    assert_difference('Post.count') do
      xhr :post, :create,
          :post => {:content => 'Test blog 2 content', :title => 'test blog 2'}
      assert_response :success
      assert_equal 'test blog 2', assigns(:post).title
      assert_equal 'Test blog 2 content', assigns(:post).content
    end
  end

  test 'edit not logged in' do
    xhr :get, :edit, :id => @post.id
    assert_login_required
  end

  test 'edit unauthorized' do
    login(@gg)
    xhr :get, :edit, :id => @post.id
    assert_unauthorized
  end

  test 'edit' do
    login(@admin)
    xhr :get, :edit, :id => @post.id
    assert_response :success
    assert_equal @post, assigns(:post)
  end

  test 'update not logged in' do
    xhr :put, :update, :id => @post.id,
        :post => {:content => 'Blah blah'}
    assert_login_required
    assert_not_equal 'Blah blah', @post.reload.content
  end

  test 'update unauthorized' do
    login(@gg)
    xhr :put, :update, :id => @post.id,
        :post => {:content => 'Blah blah'}
    assert_unauthorized
    assert_not_equal 'Blah blah', @post.reload.content
  end

  test 'update' do
    login(@admin)
    xhr :put, :update, :id => @post.id,
        :post => {:content => 'Test post'}
    assert_equal 'Test post', @post.reload.content
  end

  test 'delete not logged in' do
    assert_no_difference('Post.count') do
      xhr :delete, :destroy, :id => @post.id
      assert_login_required
    end
  end

  test 'delete unauthorized' do
    login(@gg)
    assert_no_difference('Post.count') do
      xhr :delete, :destroy, :id => @post.id
      assert_unauthorized
    end
  end

  test 'delete' do
    login(@admin)
    assert_difference('Post.count', -1) do
      xhr :delete, :destroy, :id => @post.id
      assert_response :success
    end
  end
end
