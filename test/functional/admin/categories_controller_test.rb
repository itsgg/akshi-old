require 'test_helper'

class Admin::CategoriesControllerTest < ActionController::TestCase
  setup do
    @gg = users(:gg)
    @admin = users(:admin)
    @english = categories(:english)
  end

  test 'list categories not logged in' do
    xhr :get, :index
    assert_login_required
  end

  test 'list categories unauthorized' do
    login(@gg)
    xhr :get, :index
    assert_unauthorized
  end

  test 'list categories' do
    login(@admin)
    xhr :get, :index
    assert_equal assigns(:categories), Category.all
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
    assert assigns(:category).new_record?
  end

  test 'create not logged in' do
    assert_no_difference 'Category.count' do
      xhr :post, :create, {:category => {:name => 'Category new'}}
    end
    assert_login_required
  end

  test 'create unauthorized' do
    login(@gg)
    assert_no_difference 'Category.count' do
      xhr :post, :create, {:category => {:name => 'Category new'}}
    end
    assert_unauthorized
  end

  test 'create' do
    login(@admin)
    assert_difference 'Category.count', 1 do
      xhr :post, :create, {:category => {:name => 'Category new'}}
    end
    assert_response :success
    assert_equal 'Category new', assigns(:category).name
  end

  test 'edit not logged in' do
    xhr :get, :edit, :id => @english
    assert_login_required
  end

  test 'edit unauthorized' do
    login(@gg)
    xhr :get, :edit, :id => @english
    assert_unauthorized
  end

  test 'edit' do
    login(@admin)
    xhr :get, :edit, :id => @english
    assert_response :success
    assert_equal @english, assigns(:category)
  end

  test 'update not logged in' do
    xhr :put, :update, :id => @english, :category => {:name => 'English modified'}
    assert_login_required
    assert_not_equal @english.reload.name, 'English modified'
  end

  test 'update unauthorized' do
    login(@gg)
    xhr :put, :update, :id => @english, :category => {:name => 'English modified'}
    assert_unauthorized
    assert_not_equal @english.reload.name, 'English modified'
  end

  test 'update' do
    login(@admin)
    xhr :put, :update, :id => @english, :category => {:name => 'English modified'}
    assert_response :success
    assert_equal @english.reload.name, 'English modified'
  end

  test 'delete not logged in' do
    assert_no_difference 'Category.count' do
      xhr :delete, :destroy, :id => @english
    end
    assert_login_required
  end

  test 'delete unauthorized' do
    login(@gg)
    assert_no_difference 'Category.count' do
      xhr :delete, :destroy, :id => @english
    end
    assert_unauthorized
  end

  test 'delete' do
    login(@admin)
    assert_difference 'Category.count', -1 do
      xhr :delete, :destroy, :id => @english
    end
    assert_response :success
  end

  test 'search' do
    login(@admin)
    xhr :get, :index, :q => {:name_cont => 'math'}
    assert_response :success
    assert_equal [categories(:mathematics)], assigns(:categories)
  end
end
