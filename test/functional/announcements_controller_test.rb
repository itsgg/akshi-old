require 'test_helper'

class AnnouncementsControllerTest < ActionController::TestCase
  setup do
    @gg = users(:gg)
    @akshi = users(:akshi)
    @course = @gg.teaching_courses.last
    @announcement = @course.announcements.last
  end

  test 'Index' do
    login(@akshi)
    xhr :get, :index, :course_id => @course
    assert_response :success
    assert_equal @course, assigns(:course)
    assert_equal @course.announcements, assigns(:announcements)
  end

  test 'Index with feature disabled' do
    login(@akshi)
    @course.features = ['live']
    assert @course.save
    xhr :get, :index, :course_id => @course
    assert_unauthorized
  end

  test 'New' do
    login(@gg)
    xhr :get, :new, :course_id => @course
    assert_response :success
    assert assigns(:announcement).new_record?
    assert_equal @course, assigns(:course)
  end

  test 'New without login' do
    xhr :get, :new, :course_id => @course
    assert_login_required
  end

  test 'New non-teacher' do
    login(@akshi)
    xhr :get, :new, :course_id => @course
    assert_unauthorized
  end

  test 'Edit' do
    login(@gg)
    xhr :get, :edit, :course_id => @course, :id => @announcement
    assert_response :success
    assert_equal @announcement, assigns(:announcement)
    assert_equal @course, assigns(:course)
  end

  test 'Edit without login' do
    xhr :get, :edit, :course_id => @course, :id => @announcement
    assert_login_required
  end

  test 'Edit non-teacher' do
    login(@akshi)
    xhr :get, :edit, :course_id => @course, :id => @announcement
    assert_unauthorized
  end

  test 'Create' do
    login(@gg)
    assert_difference('Announcement.count') do
      xhr :post, :create, :course_id => @course, :id => @announcement,
          :announcement => {:content => 'New announcement'}
      assert_response :success
      assert_equal @course, assigns(:course)
      assert assigns(:announcement)
    end
  end

  test 'Create without login' do
    xhr :get, :new, :course_id => @course, :id => @announcement,
        :announcement => {:content => 'New announcement'}
    assert_login_required
  end

  test 'Create non-teacher' do
    login(@akshi)
    xhr :get, :new, :course_id => @course, :id => @announcement,
        :announcement => {:content => 'New announcement'}
    assert_unauthorized
  end

  test 'Update' do
    login(@gg)
    xhr :put, :update, :course_id => @course, :id => @announcement,
        :announcement => {:content => 'Updated announcement'}
    assert_equal @course, assigns(:course)
    @announcement.reload
    assert_equal @announcement.content, 'Updated announcement'
  end

  test 'Update without login' do
    xhr :put, :update, :course_id => @course, :id => @announcement,
        :announcement => {:content => 'Updated announcement'}
    assert_login_required
  end

  test 'Update non-teacher' do
    login(@akshi)
    xhr :put, :update, :course_id => @course, :id => @announcement,
        :announcement => {:content => 'Updated announcement'}
    assert_unauthorized
  end

  test 'Delete' do
    login(@gg)
    assert_difference('Announcement.count', -1) do
      xhr :delete, :destroy, :course_id => @course, :id => @announcement
      assert_response :success
    end
  end

  test 'Delete non-teacher' do
    login(@akshi)
    assert_no_difference('Announcement.count') do
      xhr :delete, :destroy, :course_id => @course, :id => @announcement
      assert_unauthorized
    end
  end

  test 'Delete without login' do
    assert_no_difference('Announcement.count') do
      xhr :delete, :destroy, :course_id => @course, :id => @announcement
      assert_login_required
    end
  end
end
