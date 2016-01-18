# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  user_id    :integer
#  course_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class RoleTest < ActiveSupport::TestCase
  test 'presence validation' do
    role = Role.new
    assert !role.save
    assert role.errors[:name].include?('is required')
    assert role.errors[:user].include?('is required')
    assert role.errors[:course].include?('is required')
  end
end
