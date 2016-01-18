# == Schema Information
#
# Table name: quizzes
#
#  id                    :integer          not null, primary key
#  name                  :string(255)
#  instruction           :text(2147483647)
#  course_id             :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  published             :boolean          default(FALSE)
#  time_limit_in_minutes :float            default(0.0)
#  position              :integer
#  allow_review          :boolean          default(TRUE)
#  subject_id            :integer
#

class Quiz < ActiveRecord::Base
  attr_accessible :name, :instruction, :time_limit_in_minutes,
                  :course_id, :published, :position, :allow_review, :subject_ids

  validates :name, :presence => true, :length => 4..80
  validates :course_id, :presence => true
  validates :time_limit_in_minutes, :numericality => true

  belongs_to :course
  has_and_belongs_to_many :subjects
  
  has_many :questions, :dependent => :destroy
  has_many :responses, :dependent => :destroy
  has_many :scores, :dependent => :destroy
  has_many :quiz_sessions

  acts_as_readable :on => :created_at

  default_scope :order => 'quizzes.position ASC, quizzes.created_at DESC'

  scope :published, :conditions => {:published => true}

  def finish!(user_id)
    score = self.scores.find_or_create_by_user_id(user_id)
    user_responses = self.responses.where(:user_id => user_id)
    score.total_questions = self.questions.size
    score.correct_answers = 0
    user_responses.each do |response|
      if response.question.correct_answer == response.answer
        score.correct_answers += 1
      end
    end
    score.finished = true
    score.save!
  end

  def completed?(user_id)
    score = self.score(user_id)
    score && score.finished?
  end

  def score(user_id)
    score = self.scores.find_by_user_id(user_id)
  end

  def rank(user_id)
    # XXX: Performance issue. Use SQL directly
    rank = nil
    partition_count = 1
    sorted_scores = self.scores.order('correct_answers DESC')
    sorted_scores.each_with_index do |score, index|
      if index == 0
        rank = 1
      else
        previous_score = sorted_scores[index - 1]
        if score.correct_answers == previous_score.correct_answers
          partition_count += 1
        else
          rank += partition_count
          partition_count = 1
        end
      end
      break if score.user_id == user_id
    end
    return rank
  end

  def has_time_limit?
    self.time_limit_in_minutes > 0
  end

  def start!(user_id)
    user = User.find(user_id)
    quiz_session = QuizSession.where(:user_id => user_id, :quiz_id => self.id).first
    if quiz_session.present?
      quiz_session.touch(:created_at)
      quiz_session.touch(:updated_at)
    else
      quiz_session = QuizSession.create!(:user => User.find(user_id),
                                             :quiz => self)
    end
    self.quiz_sessions << quiz_session
  end

  def current_session(user_id)
    QuizSession.where(:user_id => user_id, :quiz_id => self.id).select do |quiz_session|
      quiz_session
    end.first
  end

  def to_param
    return id if self.name.blank?
    "#{id}-#{self.name.downcase.gsub(/[^a-zA-Z0-9]+/, '-')
                               .gsub(/-{2,}/, '-')
                               .gsub(/^-|-$/, '')}"
  end
end
