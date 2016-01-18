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

class Response < ActiveRecord::Base
  attr_accessible :user_id, :answer_id, :quiz_id, :question_id

  scope :correct, joins(:question).where('responses.answer_id = questions.correct_answer_id')

  belongs_to :answer
  belongs_to :user
  belongs_to :quiz
  belongs_to :question

  validates :answer_id, :presence => true
  validates :user_id, :presence => true
  validates :quiz_id, :presence => true
  validates :question_id, :presence => true

end
