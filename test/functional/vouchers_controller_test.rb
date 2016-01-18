require 'test_helper'

class VouchersControllerTest < ActionController::TestCase
  setup do
    @gg = users(:gg)
    @akshi = users(:akshi)
    @math = courses(:math101)
    @voucher = @math.vouchers.last
  end

  test 'index not logged in' do
    xhr :get, :index, :course_id => @math.id
    assert_login_required
  end

  test 'index unauthorized' do
    login(@akshi)
    xhr :get, :index, :course_id => @math.id
    assert_unauthorized
  end

  test 'index' do
    login(@gg)
    xhr :get, :index, :course_id => @math.id
    assert_equal @math, assigns(:course)
    assert_array_equal(@math.vouchers, assigns(:vouchers), :code)
  end

  test 'delete not logged in' do
    assert_no_difference('Voucher.count') do
      xhr :delete, :destroy, :course_id => @math.id, :id => @math.vouchers.last
    end
    assert_login_required
  end

  test 'delete unauthorized in' do
    login(@akshi)
    assert_no_difference('Voucher.count') do
      xhr :delete, :destroy, :course_id => @math.id, :id => @math.vouchers.last
    end
    assert_unauthorized
  end

  test 'delete' do
    login(@gg)
    assert_difference('Voucher.count', -1) do
      xhr :delete, :destroy, :course_id => @math.id, :id => @math.vouchers.last
    end
    assert_equal 'Deleted', flash[:notice]
  end

  test 'update not logged in' do
    @voucher.deactivate!
    xhr :put, :update, :course_id => @math, :id => @voucher, :voucher => { :status => 'active' }
    assert_login_required
  end

  test 'update unauthorized' do
    login(@akshi)
    @voucher.deactivate!
    xhr :put, :update, :course_id => @math, :id => @voucher, :voucher => { :status => 'active' }
    assert_unauthorized
  end

  test 'update' do
    login(@gg)
    @voucher.deactivate!
    xhr :put, :update, :course_id => @math, :id => @voucher, :voucher => { :status => 'active' }
    assert assigns(:voucher).status_active?
    assert 'Updated', flash[:notice]
  end
end
