require 'test_helper'

class Admin::CollectionsControllerTest < ActionController::TestCase
  setup do
    @gg = users(:gg)
    @admin = users(:admin)
    @engineering = collections(:engineering_coaching)
  end

  test 'list collections not logged in' do
    xhr :get, :index
    assert_login_required
  end

  test 'list collections unauthorized' do
    login(@gg)
    xhr :get, :index
    assert_unauthorized
  end

  test 'list collections' do
    login(@admin)
    xhr :get, :index
    assert_equal assigns(:collections), Collection.arrange
  end

  test 'edit not logged in' do
    xhr :get, :edit, :id => @engineering
    assert_login_required
  end

  test 'edit unauthorized' do
    login(@gg)
    xhr :get, :edit, :id => @engineering
    assert_unauthorized
  end

  test 'edit' do
    login(@admin)
    xhr :get, :edit, :id => @engineering
    assert_response :success
    assert_equal @engineering, assigns(:collection)
  end

  test 'update not logged in' do
    xhr :put, :update, :id => @engineering, :collection => {:name => 'Collection modified'}
    assert_login_required
    assert_not_equal @engineering.reload.name, 'Collection modified'
  end

  test 'update unauthorized' do
    login(@gg)
    xhr :put, :update, :id => @engineering, :collection => {:name => 'Collection modified'}
    assert_unauthorized
    assert_not_equal @engineering.reload.name, 'Collection modified'
  end

  test 'update' do
    login(@admin)
    xhr :put, :update, :id => @engineering, :collection => {:name => 'Collection modified'}
    assert_response :success
    assert_equal @engineering.reload.name, 'Collection modified'
  end

  test 'delete not logged in' do
    assert_no_difference 'Collection.count' do
      xhr :delete, :destroy, :id => @engineering
    end
    assert_login_required
  end

  test 'delete unauthorized' do
    login(@gg)
    assert_no_difference 'Collection.count' do
      xhr :delete, :destroy, :id => @engineering
    end
    assert_unauthorized
  end

  test 'delete' do
    login(@admin)
    assert_difference 'Collection.count', -1 do
      xhr :delete, :destroy, :id => @engineering
    end
    assert_response :success
  end
end
