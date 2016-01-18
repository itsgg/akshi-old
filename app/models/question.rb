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

class Question < ActiveRecord::Base
  attr_accessible :content, :quiz_id, :correct_answer_id

  belongs_to :quiz
  has_many :answers, :dependent => :destroy
  has_many :responses, :dependent => :destroy
  belongs_to :correct_answer, :class_name => 'Answer'

  validates :content, :presence => true
  validates :quiz_id, :presence => true

  def student_answer(user_id)
    student_responses = self.responses.where(:user_id => user_id)
    student_responses.last.answer if student_responses.present?
  end

  def student_answer_alpha_index(user_id)
    answer_alpha_index(student_answer(user_id).id)
  end

  def correct_answer_alpha_index
    answer_alpha_index(self.correct_answer_id)
  end

  def answer_index(answer_id)
    self.answers.map(&:id).index(answer_id)
  end

  def answer_alpha_index(answer_id)
    (answer_index(answer_id) + 97).chr
  end

  def correct?(user_id)
    student_answer(user_id).try(:id) == self.correct_answer_id
  end
end
