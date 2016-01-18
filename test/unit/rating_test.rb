# == Schema Information
#
# Table name: ratings
#
#  id           :integer          not null, primary key
#  owner_id     :integer
#  ratable_id   :integer
#  ratable_type :string(255)
#  score        :float
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'test_helper'

class RatingTest < ActiveSupport::TestCase

  test 'presence validation' do
    rating = Rating.new
    assert !rating.save
    assert rating.errors[:owner_id].include?('is required')
    assert rating.errors[:ratable_id].include?('is required')
    assert rating.errors[:ratable_type].include?('is required')
    assert rating.errors[:score].include?('is required')
  end
end
