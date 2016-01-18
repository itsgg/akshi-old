require 'test_helper'

class LivesControllerTest < ActionController::TestCase
  test 'show unauthorized' do
    course = courses(:eng101)
    xhr :get, :show, :course_id => course
    assert_login_required
  end

  test 'show' do
    login(users(:gg))
    course = courses(:eng101)
    xhr :get, :show, :course_id => course
    assert_equal course, assigns(:course)
  end

  test 'show feature disabled' do
    login(users(:gg))
    course = courses(:eng101)
    course.features = ['quiz']
    assert course.save
    xhr :get, :show, :course_id => course
    assert_unauthorized
  end
end
