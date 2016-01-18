# == Schema Information
#
# Table name: questions
#
#  id                :integer          not null, primary key
#  content           :text(2147483647)
#  quiz_id           :integer
#  correct_answer_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'test_helper'

class QuestionTest < ActiveSupport::TestCase
  setup do
    @question = questions(:one)
    @akshi = users(:akshi)
  end

  test 'presence validation' do
    question = Question.new
    assert !question.save
    assert question.errors[:content].include?('is required')
    assert question.errors[:quiz_id].include?('is required')
  end

  test 'correct?' do
    assert @question.correct?(@akshi.id)
  end

  test 'correct_answer_alpha_index' do
    assert_equal 'a', @question.correct_answer_alpha_index
  end

  test 'student_answer_alpha_index' do
    assert_equal 'a', @question.student_answer_alpha_index(@akshi.id)
  end
end
