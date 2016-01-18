# == Schema Information
#
# Table name: answers
#
#  id          :integer          not null, primary key
#  content     :text(2147483647)
#  question_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'test_helper'

class AnswerTest < ActiveSupport::TestCase
  test 'presence validation' do
    answer = Answer.new
    assert !answer.save
    assert answer.errors[:content].include?('is required')
    assert answer.errors[:question_id].include?('is required')
  end
end
