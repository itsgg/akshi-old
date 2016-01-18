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

require 'test_helper'

class QuizTest < ActiveSupport::TestCase
  setup do
    @quiz = quizzes(:verbs)
    @gg = users(:gg)
  end

  test 'presence validation' do
    quiz = Quiz.new
    assert !quiz.save
    assert quiz.errors[:name].include?('is required')
    assert quiz.errors[:course_id].include?('is required')
  end

  test 'length validation' do
    quiz = quizzes(:verbs)
    quiz.name = random_string(90)
    assert !quiz.save
    assert quiz.errors[:name].include?('max 80 characters')

    quiz = quizzes(:test)
    quiz.name = random_string(3)
    assert !quiz.save
    assert quiz.errors[:name].include?('min 4 characters')
  end

  test 'numericality validation' do
    quiz = quizzes(:verbs)
    quiz.time_limit_in_minutes = 'a'
    assert !quiz.save
    assert quiz.errors[:time_limit_in_minutes].include?('is not a number')
  end

  test 'finish' do
    Score.delete_all
    user = users(:akshi)
    quiz = quizzes(:prob)
    quiz.finish!(user.id)
    assert quiz.score(user.id).finished
    assert_equal 100.0, quiz.score(user.id).percent
    user = users(:akshi)
    quiz = quizzes(:verbs)
    quiz.finish!(user.id)
    assert quiz.score(user.id).finished
    assert_equal 0, quiz.score(user.id).percent
  end

  test 'rank' do
    course = courses(:math101)
    quiz = Quiz.create! :name => 'Test quiz', :course_id => course.id,
                        :published => true
    one = User.create! :username => 'one', :password => 'oneone',
                       :password_confirmation => 'oneone',
                       :email => 'one@akshi.com', :fullname => 'one'
    two = User.create! :username => 'two', :password => 'twotwo',
                       :password_confirmation => 'twotwo',
                       :email => 'two@akshi.com', :fullname => 'two'
    three = User.create! :username => 'three', :password => 'threethree',
                         :password_confirmation => 'threethree',
                         :email => 'three@akshi.com', :fullname => 'three'
    four = User.create! :username => 'four', :password => 'fourfour',
                        :password_confirmation => 'fourfour',
                        :email => 'four@akshi.com', :fullname => 'four'
    five = User.create! :username => 'five', :password => 'fivefive',
                         :password_confirmation => 'fivefive',
                         :email => 'five@akshi.com', :fullname => 'five'
    Score.create! :user_id => one.id, :quiz_id => quiz.id,
                  :total_questions => 5, :correct_answers => 2
    Score.create! :user_id => two.id, :quiz_id => quiz.id,
                  :total_questions => 5, :correct_answers => 2
    Score.create! :user_id => three.id, :quiz_id => quiz.id,
                  :total_questions => 5, :correct_answers => 3
    Score.create! :user_id => four.id, :quiz_id => quiz.id,
                  :total_questions => 5, :correct_answers => 1
    Score.create! :user_id => five.id, :quiz_id => quiz.id,
                  :total_questions => 5, :correct_answers => 4

    assert_equal 1, quiz.rank(five.id)
    assert_equal 2, quiz.rank(three.id)
    assert_equal 3, quiz.rank(one.id)
    assert_equal 3, quiz.rank(two.id)
    assert_equal 5, quiz.rank(four.id)
  end

  test 'has_time_limit?' do
    quiz = quizzes(:verbs)
    assert !quiz.has_time_limit?
    quiz.time_limit_in_minutes = 30
    quiz.save!
    assert quiz.has_time_limit?
  end

  test 'current_session' do
    QuizSession.delete_all
    @quiz.start!(@gg.id)
    assert @gg.quiz_session
    assert_equal @gg.quiz_session, @quiz.current_session(@gg.id)
  end

  test 'should reuse existing quiz session' do
    QuizSession.delete_all
    @quiz.start!(@gg.id)
    session_id = @gg.quiz_session.id
    session_start_time = @gg.quiz_session.created_at
    sleep(2)
    @quiz.start!(@gg.id)
    assert_equal session_id, @gg.quiz_session.id
    assert_not_equal session_start_time, @gg.quiz_session.reload.created_at
  end

  test 'to_param' do
    @quiz.name = 'Hello % test quiz'
    @quiz.save!
    assert_equal "#{@quiz.id}-hello-test-quiz", @quiz.to_param
  end
end
