require 'test_helper'

class VouchersTest < ActionDispatch::IntegrationTest
  setup do
    @gg = users(:gg)
    @gg.password = @gg.password_confirmation = 'foobar'
    @gg.save!
    @admin = users(:admin)
    @admin.password = @admin.password_confirmation = 'foobar'
    @admin.save!
    @akshi = users(:akshi)
    @akshi.password = @akshi.password_confirmation = 'foobar'
    @akshi.save!
  end

  def create_vouchers
    login(@gg)
    within('#main-menu') do
      click_link 'Teach'
    end
    find('#main-menu li.active:contains("Teach")')
    within('#content') do
      click_link 'New'
    end
    fill_in 'Name', :with => 'Test course'
    click_button 'Create'
    find('.flash-info:contains("Created")')
    find('.page-header h4:contains("Test course")')
    within('#main-menu') do
      click_link 'Home'
    end
    assert has_no_content?('Test course')
    within('#main-menu') do
      click_link 'Teach'
    end
    find('#main-menu li.active:contains("Teach")')
    click_link 'Test course'
    find(".page-header h4:contains('Test course')")
    check 'course_published'
    check 'course_paid'
    fill_in 'Amount', :with => 100.0
    click_button 'Update'
    find('.flash-info:contains("Updated")')
    root_path
    within('#main-menu') do
      click_link 'Logout'
    end
    find('.flash-info:contains("Logged out")')
    login(@admin)
    within('#main-menu') do
      click_link 'Admin'
    end
    click_link 'Courses'
    click_link 'Accept'
    accept_dialog
    find('.flash-info:contains("Published")')
    within('#main-menu') do
      click_link 'Logout'
    end
    find('.flash-info:contains("Logged out")')
    login(@gg)
    within('#main-menu') do
      click_link 'Teach'
    end
    click_link 'Test course'
    click_link 'Vouchers'
    find('.modal-header h4:contains("Vouchers")')
    find('.alert:contains("No vouchers found")')
    click_button 'Generate'
    find('.alert:contains("Generated 5 vouchers")')
    click_button 'Close'
    click_link 'Vouchers'
  end

  test 'create vouchers' do
    create_vouchers
  end

  test 'activate vouchers' do
    create_vouchers
    within "#voucher_#{Voucher.last.id}" do
      click_link 'Activate'
    end
    find('.alert:contains("Updated")')
  end

  test 'deactivate vouchers' do
    create_vouchers
    within "#voucher_#{Voucher.last.id}" do
      click_link 'Activate'
    end
    click_button 'Close'
    click_link 'Vouchers'
    within "#voucher_#{Voucher.last.id}" do
      click_link 'Deactivate'
    end
    find('.alert:contains("Updated")')
  end

  test 'delete vouchers' do
    create_vouchers
    within "#voucher_#{Voucher.last.id}" do
      click_link 'Delete'
    end
    accept_dialog
    find('.alert:contains("Deleted")')
  end

  test 'enroll with invalid voucher' do
    create_vouchers
    visit root_path
    within('#main-menu') do
      click_link 'Logout'
    end
    find('.flash-info:contains("Logged out")')
    login(@akshi)
    click_link 'Test course'
    click_link 'Enroll'
    fill_in 'Voucher code', :with => 12312
    click_button 'Enroll'
    find('.alert:contains("Invalid voucher code")')
  end

  test 'enroll with inactive voucher' do
    create_vouchers
    visit root_path
    within('#main-menu') do
      click_link 'Logout'
    end
    find('.flash-info:contains("Logged out")')
    login(@akshi)
    click_link 'Test course'
    click_link 'Enroll'
    fill_in 'Voucher code', :with => Voucher.last.code
    click_button 'Enroll'
    find('.alert:contains("Invalid voucher code")')
  end

  test 'active Voucher' do
    create_vouchers
    within "#voucher_#{Voucher.last.id}" do
      click_link 'Activate'
    end
    find('.alert:contains("Updated")')
    visit root_path
    within('#main-menu') do
      click_link 'Logout'
    end
    find('.flash-info:contains("Logged out")')
    login(@akshi)
    click_link 'Test course'
    click_link 'Enroll'
    fill_in 'Voucher code', :with => Voucher.last.code
    click_button 'Enroll'
    find('.flash-info:contains("Enrolled")')
  end

  test 'enroll free course with admin' do
    login(@gg)
    within('#main-menu') do
      click_link 'Teach'
    end
    find('#main-menu li.active:contains("Teach")')
    within('#courses') do
      click_link 'Mathematics 101'
    end
    find('.page-header h4:contains("Mathematics 101")')
    check 'course_published'
    click_button 'Update'
    find('.flash-info:contains("Updated")')
    find('.alert:contains("Course is under review")')
    within('#main-menu') do
      click_link 'Logout'
    end
    find('.flash-info:contains("Logged out")')
    login(@admin)
    within('#main-menu') do
      click_link 'Admin'
    end
    click_link 'Courses'
    click_link 'Mathematics 101'
    click_link 'Enroll'
    find('.flash-info:contains("Enrolled")')
    find('.btn:contains("Drop out")')
  end

  test 'enroll Paid course with admin' do
    login(@gg)
    within('#main-menu') do
      click_link 'Teach'
    end
    find('#main-menu li.active:contains("Teach")')
    within('#content') do
      click_link 'New'
    end
    fill_in 'Name', :with => 'Test course'
    click_button 'Create'
    find('.flash-info:contains("Created")')
    find('.page-header h4:contains("Test course")')
    within('#main-menu') do
      click_link 'Home'
    end
    assert has_no_content?('Test course')
    within('#main-menu') do
      click_link 'Teach'
    end
    find('#main-menu li.active:contains("Teach")')
    click_link 'Test course'
    find(".page-header h4:contains('Test course')")
    check 'course_published'
    check 'course_paid'
    fill_in 'Amount', :with => 100.0
    click_button 'Update'
    find('.flash-info:contains("Updated")')
    find('.alert:contains("Course is under review")')
    within('#main-menu') do
      click_link 'Logout'
    end
    find('.flash-info:contains("Logged out")')
    login(@admin)
    within('#main-menu') do
      click_link 'Admin'
    end
    click_link 'Courses'
    click_link 'Test course'
    click_link 'Enroll'
    find('.flash-info:contains("Enrolled")')
  end

  test 'filter' do
    create_vouchers
    @course = Course.last
    select 'All', :from => 'voucher_filter'
    assert has_content?("#{@course.vouchers.first.code}")
    select 'New', :from => 'voucher_filter'
    assert has_content?("#{@course.vouchers.available.first.code}")
    select 'Used', :from => 'voucher_filter'
    find('.alert:contains("No vouchers found")')
    select 'Active', :from => 'voucher_filter'
    find('.alert:contains("No vouchers found")')
  end
end
