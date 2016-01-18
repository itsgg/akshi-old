require 'test_helper'

class SchedulesControllerTest < ActionController::TestCase
  setup do
    @gg = users(:gg)
    @course = @gg.teaching_courses.last
    @akshi = users(:akshi)
  end

  test 'index unauthorized' do
    xhr :get, :index, :course_id => @course.id
    assert_login_required
  end

  test 'index' do
    login(@gg)
    xhr :get, :index, :course_id => @course.id
    assert_response :success
    assert assigns(:schedule).new_record?
  end

  test 'create unauthorized' do
    login(@akshi)
    xhr :post, :create, :course_id => @course.id,
        :schedule => {:description => 'foobar', :start_time => 'tomorrow'}
    assert_unauthorized
  end

  test 'delete unauthorized' do
    login(@akshi)
    assert_no_difference('Schedule.count') do
      xhr :delete, :destroy, :course_id => @course.id, :id => @course.schedules.last
    end
    assert_unauthorized
  end

  test 'create' do
    login(@gg)
    assert_difference('Schedule.count') do
      xhr :post, :create, :course_id => @course.id,
          :schedule => {:description => 'foobar', :start_time => 'tomorrow'}
    end
    assert_equal 'Scheduled', flash[:notice]
    assert_equal 'foobar', assigns(:schedule).description

    assert_no_difference('Schedule.count') do
      xhr :post, :create, :course_id => @course.id,
          :schedule => {:description => 'foobar', :start_time => 'foobar'}
    end
    assert_equal 'Start time is invalid', flash[:error]

    assert_no_difference('Schedule.count') do
      xhr :post, :create, :course_id => @course.id,
          :schedule => {:description => 'foobar', :start_time => 'yesterday'}
    end
    assert_equal 'Start time should be in future', flash[:error]
  end

  test 'delete' do
    login(@gg)
    assert_difference('Schedule.count', -1) do
      xhr :delete, :destroy, :course_id => @course.id, :id => @course.schedules.last
    end
    assert_equal 'Deleted', flash[:notice]
  end
end
