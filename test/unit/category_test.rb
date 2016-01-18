# == Schema Information
#
# Table name: categories
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  position   :integer
#

require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  test 'prsence validation' do
    category = Category.new
    assert !category.save
    assert category.errors[:name].include?('is required')
  end

  test 'unique validation' do
    category = Category.new(:name => 'English')
    assert !category.save
    assert category.errors[:name].include?('is taken')
  end

  test 'length validation' do
    category = Category.new(:name => random_string(3))
    assert !category.save
    assert category.errors[:name].include?('min 4 characters')
    category = Category.new(:name => random_string(90))
    assert !category.save
    assert category.errors[:name].include?('max 80 characters')
  end

  test 'order!' do
    assert_equal Category.all.map(&:id),
                 [categories(:english), categories(:mathematics), categories(:computer)].map(&:id)
    ordered_categories = [categories(:mathematics), categories(:computer), categories(:english)]
    Category.order!(ordered_categories.map(&:id))
    assert_equal Category.all.map(&:id),
                 ordered_categories.map(&:id)
  end
end
