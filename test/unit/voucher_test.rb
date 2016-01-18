# == Schema Information
#
# Table name: vouchers
#
#  id         :integer          not null, primary key
#  code       :string(255)
#  status     :string(255)      default("new")
#  course_id  :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class VoucherTest < ActiveSupport::TestCase
  setup do
    @course = courses(:eng101)
    @voucher = vouchers(:one)
  end

  test 'presence validation' do
    voucher = Voucher.new
    assert !voucher.save
    assert voucher.errors[:code].include?('is required')
    assert voucher.errors[:course_id].include?('is required')
  end

  test 'generate' do
    assert_difference('Voucher.count', 10) do
      Voucher.generate!(@course.id)
    end
  end

  test 'generate unique code' do
    assert_nothing_raised do
      vouchers = Voucher.generate!(@course.id, 2, 2, ['1', '2'])
    end

    assert_raise RuntimeError do
      vouchers = Voucher.generate!(@course.id, 2, 2, ['1'])
    end
  end

  test 'uniqueness' do
    course_one = courses(:eng101)
    course_two = courses(:ruby101)
    voucher = Voucher.new(:course_id => course_one.id, :code => 'abc')
    voucher.save!
    voucher = Voucher.new(:course_id => course_two.id, :code => 'abc')
    voucher.save!
    voucher = Voucher.new(:course_id => course_one.id, :code => 'abc')
    assert !voucher.save
    assert voucher.errors[:code].include?('is taken')
  end

  test 'status' do
    assert_equal 'new', @voucher.status
    @voucher.activate!
    assert_equal 'active', @voucher.status
    assert @voucher.status_active?
    assert @voucher.status_valid?
    @voucher.use!
    assert_equal 'used', @voucher.status
    assert @voucher.status_used?
    @voucher.deactivate!
    assert_equal 'new', @voucher.status
    assert @voucher.status_new?
  end

  test 'status_valid?' do
    assert !vouchers(:one).status_valid?
    assert !vouchers(:two).status_valid?
    assert vouchers(:three).status_valid?
  end

  test 'filter' do
    assert_array_equal Voucher.filter(@course, {}),
                       @course.vouchers.all,
                       :id
    assert_equal Voucher.filter(@course, {:filter => 'New'}),
                 [vouchers(:one)]
    assert_equal Voucher.filter(@course, {:filter => 'Used'}),
                 [vouchers(:one_three)]
    assert_equal Voucher.filter(@course, {:filter => 'Active'}),
                 [vouchers(:one_two)]
    assert_equal Voucher.filter(@course, {:q => {'code_cont' => vouchers(:one_two).code}}),
                 [vouchers(:one_two)]
  end
end
