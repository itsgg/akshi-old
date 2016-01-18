# == Schema Information
#
# Table name: scores
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  quiz_id         :integer
#  total_questions :integer          default(0)
#  correct_answers :integer          default(0)
#  start_time      :datetime
#  finished        :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'test_helper'

class ScoreTest < ActiveSupport::TestCase
  test 'presence validations' do
    score = Score.new
    assert !score.save
    assert score.errors[:user_id].include?('is required')
    assert score.errors[:quiz_id].include?('is required')
  end

  test 'percent' do
    score = Score.first
    score.total_questions = 13
    score.correct_answers = 3
    score.save!
    assert_equal 23.1, score.percent
  end

  test 'finished' do
    Score.finished.each do |score|
      assert score.finished?
    end
  end
end
