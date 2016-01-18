require 'test_helper'

class EnrollmentTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(:username => 'userone', :password => 'password',
                         :fullname => 'User one', :email => 'one@akshi.com',
                         :password_confirmation => 'password')
    @gg = users(:gg)
    @gg.password = @gg.password_confirmation = 'password'
    @gg.save!
    @akshi = users(:akshi)
    @akshi.password = @akshi.password_confirmation = 'password'
    @akshi.save!
  end

  test 'enroll' do
    eng = courses(:eng101)
    login(@user)
    within('#courses') do
      click_link eng.name
    end
    find(".page-header h4:contains('#{eng.name}')")
    within('#content') do
      click_link 'Enroll'
    end
    find('.flash-info:contains("Enrolled")')
    within('#main-menu') do
      click_link 'Learn'
    end
    assert has_content?(eng.name)
  end

  test 'dropout free course' do
    course = courses(:comp101)
    login(@gg)
    within('#main-menu') do
      click_link 'Learn'
    end
    find('#main-menu li.active:contains("Learn")')
    assert has_content?(course.name)
    within('#content') do
      click_link course.name
    end
    within('#content') do
      click_link 'Drop out'
    end
    accept_dialog
    find('.flash-info:contains("Dropped out")')
    within('#main-menu') do
      click_link 'Learn'
    end
    assert has_no_content?(course.name)
  end

  test 'dropout paid course' do
    course = courses(:blah101)
    login(@akshi)
    within('#main-menu') do
      click_link 'Learn'
    end
    find('#main-menu li.active:contains("Learn")')
    assert has_content?(course.name)
    within('#content') do
      click_link course.name
    end
    within('#content') do
      assert has_content?('To dropout of this course for any reason please contact admin@akshi.com')
    end
  end
end
