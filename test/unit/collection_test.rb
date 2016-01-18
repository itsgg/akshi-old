# == Schema Information
#
# Table name: collections
#
#  id                          :integer          not null, primary key
#  name                        :string(255)
#  ancestry                    :string(255)
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  position                    :integer
#  description                 :text
#  cover_file_name             :string(255)
#  cover_content_type          :string(255)
#  cover_file_size             :integer
#  cover_updated_at            :datetime
#  discount                    :integer
#  offline_payment_instruction :text
#  paid                        :boolean          default(TRUE)
#

require 'test_helper'

class CollectionTest < ActiveSupport::TestCase
  test 'prsence validation' do
    collection = Collection.new
    assert !collection.save
    assert collection.errors[:name].include?('is required')
  end

  test 'length validation' do
    collection = Collection.new(:name => random_string(2))
    assert !collection.save
    assert collection.errors[:name].include?('min 3 characters')
    collection = Collection.new(:name => random_string(90))
    assert !collection.save
    assert collection.errors[:name].include?('max 80 characters')
  end

  test 'tree' do
    foundation_engineering = collections(:foundation_engineering)
    assert_equal foundation_engineering.name,
                 Collection.tree([foundation_engineering])[0][:label]
  end
end
