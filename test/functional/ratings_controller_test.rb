require 'test_helper'

class RatingsControllerTest < ActionController::TestCase
  setup do
    @gg = users(:gg)
    @akshi = users(:akshi)
    @course = @gg.teaching_courses.last
  end

  test 'create not logged in' do
    assert_no_difference('Rating.count') do
      xhr :post, :create, :course_id => @course, :ratings => {:score => 3}
    end
    assert_login_required
  end

  test 'create unauthorized' do
    login(@gg)
    assert_no_difference('Rating.count') do
      xhr :post, :create, :course_id => @course, :ratings => {:score => 3}
    end
    assert_unauthorized
  end

  test 'create' do
    login(@akshi)
    assert_difference('Rating.count') do
      xhr :post, :create, :course_id => @course, :ratings => {:score => 3}
    end
    assert_response :success
    assert_equal 'Rating successful', flash.notice
  end
end
