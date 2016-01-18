require 'test_helper'

class CourseObserverTest < ActiveSupport::TestCase
  setup do
    @course = courses(:math101)
    @gg = users(:gg)
    @admin = users(:admin)
  end

  test 'observable Comment Model' do
    assert_equal Course, CourseObserver.observed_class
  end
end
