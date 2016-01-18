# == Schema Information
#
# Table name: responses
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  question_id :integer
#  answer_id   :integer
#  quiz_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'test_helper'

class ResponseTest < ActiveSupport::TestCase
  test 'presence validation' do
    response = Response.new
    assert !response.save
    assert response.errors[:user_id].include?('is required')
    assert response.errors[:answer_id].include?('is required')
    assert response.errors[:quiz_id].include?('is required')
    assert response.errors[:question_id].include?('is required')
  end
end
