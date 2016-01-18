require 'test_helper'

class QuizTest < ActionDispatch::IntegrationTest
  setup do
    @gg = users(:gg)
    @gg.password = @gg.password_confirmation = 'foobar'
    @gg.save!
    @akshi = users(:akshi)
    @akshi.password = @akshi.password_confirmation = 'foobar'
    @akshi.save!
    @candidate = User.create(:username => "client", :fullname => "Client", :email => "client@akshi.com",
                             :password => "foobar", :password_confirmation => "foobar")

    @course = courses(:eng101)
    @quiz = quizzes(:verbs)
    @question = questions(:two)
  end

  def show_new
    login(@gg)
    visit root_path
    within('#main-menu') do
      click_link 'Teach'
    end
    click_link @course.name
    find(".page-header h4:contains('#{@course.name}')")
    within('#content') do
      click_link 'Quizzes'
    end
    find('.nav-tabs li.active a:contains("Quizzes")')
    click_link 'New'
  end

  test 'Create' do
    show_new
    within('.modal-body') do
      fill_in 'Name', :with => 'Test quiz'
    end
    click_button 'Create'
    find('.flash-info:contains("Created")')
    assert has_content?('Test quiz')
  end

  test 'Update' do
    quiz_name = 'Foobar'
    quiz_instruction = 'Foobar updated'
    show_new
    within('.modal-body') do
      fill_in 'Name', :with => quiz_name
    end
    find(:css, "#quiz_published").set(true)
    click_button 'Create'
    find('.flash-info:contains("Created")')
    assert has_content?(quiz_name)
    find(".tabs-left li.active a:contains('#{quiz_name}')")
    within('#quizzes') do
      fill_in 'Name', :with => 'Foobar updated'
      click_button 'Update'
    end
    find('.flash-info:contains("Updated")')
    within('#quizzes') do
      fill_in 'Name', :with => ''
      click_button 'Update'
    end
    find('.flash-error:contains("Update failed")')
  end

  test 'delete' do
    show_new
    within('.modal-body') do
      fill_in 'Name', :with => 'quiz one'
    end
    click_button 'Create'
    find('.flash-info:contains("Created")')
    assert has_content?('quiz one')
    click_link 'delete_quiz'
    accept_dialog
    find('.flash-info:contains("Deleted")')
    assert has_no_content?('quiz one')
  end

  test 'Add/Edit/Delete question' do
    login(@gg)
    visit root_path
    within('#courses') do
      click_link @course.name
    end
    find(".page-header h4:contains('#{@course.name}')")
    within('.nav-tabs') do
      click_link 'Quizzes'
    end
    find('.nav-tabs li.active a:contains("Quizzes")')
    assert has_content?(@quiz.name)
    click_link @quiz.name
    click_link 'Questions'
    find('#quizzes .nav-tabs li.active a:contains("Questions")')
    click_link 'New question'
    fill_in_editor 'question_content', :with => 'New question'
    click_button 'Create'
    find('.flash-info:contains("Created")')
    assert has_content?('New question')
    click_link 'edit_question'
    fill_in_editor 'question_content', :with => 'New question - Updated'
    click_button 'Update'
    find('.flash-info:contains("Updated")')
    assert has_content?('New question - Updated')
    click_link 'delete_question'
    accept_dialog
    find('.flash-info:contains("Deleted")')
    assert has_no_content?('New question - Updated')
  end

  test 'add/edit/delete answers' do
    login(@gg)
    visit root_path
    within('#courses') do
      click_link @course.name
    end
    find(".page-header h4:contains('#{@course.name}')")
    within('.nav-tabs') do
      click_link 'Quizzes'
    end
    find('.nav-tabs li.active a:contains("Quizzes")')
    assert has_content?(@quiz.name)
    click_link @quiz.name
    click_link 'Questions'
    find('#quizzes .nav-tabs li.active a:contains("Questions")')
    assert has_content?(@question.content)
    click_link 'add_answer'
    fill_in_editor 'answer_content', :with => 'test answer'
    click_button 'Create'
    find('.flash-info:contains("Created")')
    assert has_content?('test answer')
    answer = @question.answers.first
    click_link "edit_#{answer.id}"
    fill_in_editor 'answer_content', :with => "#{answer.content} - Updated"
    click_button 'Update'
    find('.flash-info:contains("Update")')
    assert has_content?("#{answer.content} - Updated")
    click_link "delete_#{answer.id}"
    accept_dialog
    assert has_no_content?("#{answer.content} - Updated")
  end

  test 'select correct answer' do
    login(@gg)
    @question.correct_answer = nil
    @question.save!
    visit root_path
    within('#courses') do
      click_link @course.name
    end
    find(".page-header h4:contains('#{@course.name}')")
    within('.nav-tabs') do
      click_link 'Quizzes'
    end
    find('.nav-tabs li.active a:contains("Quizzes")')
    assert has_content?(@quiz.name)
    click_link @quiz.name
    click_link 'Questions'
    find('#quizzes .nav-tabs li.active a:contains("Questions")')
    assert has_content?(@question.content)
    assert has_content?("No correct answer selected")
    click_link 'add_answer'
    fill_in_editor 'answer_content', :with => 'test answer'
    click_button 'Create'
    find('.flash-info:contains("Created")')
    assert has_content?('test answer')
    answer = @question.answers.first
    choose("correct-answer_#{answer.id}")
    find('.flash-info:contains("Updated")')
    assert has_no_content?("No correct answer selected")
  end

  test 'take test' do
    login(@akshi)
    visit root_path
    within('#courses') do
      click_link @course.name
    end
    find(".page-header h4:contains('#{@course.name}')")
    within('.nav-tabs') do
      click_link 'Quizzes'
    end
    find('.nav-tabs li.active a:contains("Quizzes")')
    assert has_content?(@quiz.name)
    click_link @quiz.name
    assert has_content?(@quiz.instruction)
    click_link 'start_quiz'
    accept_dialog
    assert has_content?(@question.content)
    answer = @question.answers.first
    choose("selected-answer_#{answer.id}")
    click_link 'complete_quiz'
    accept_dialog
    assert has_content?("Quiz completed ")
  end

  test 'publish' do
    show_new
    within('.modal-body') do
      fill_in 'Name', :with => 'Test quiz one'
    end
    click_button 'Create'
    find('.flash-info:contains("Created")')
    assert has_content?('Test quiz one')
    click_link 'Logout'
    find('.flash-info:contains("Logged out")')
    login(@akshi)
    visit root_path
    within('#courses') do
      click_link @course.name
    end
    find(".page-header h4:contains('#{@course.name}')")
    within('.nav-tabs') do
     click_link 'Quizzes'
    end
    find('.nav-tabs li.active a:contains("Quizzes")')
    assert has_no_content?("Test quiz one")
  end

  test 'ranking' do
    login(@akshi)
    visit root_path
    within('#courses') do
      click_link @course.name
    end
    find(".page-header h4:contains('#{@course.name}')")
    within('.nav-tabs') do
      click_link 'Quizzes'
    end
    find('.nav-tabs li.active a:contains("Quizzes")')
    assert has_content?(@quiz.name)
    click_link @quiz.name
    assert has_content?(@quiz.instruction)
    click_link 'start_quiz'
    accept_dialog
    assert has_content?(@question.content)
    answer = @question.answers.first
    choose("selected-answer_#{answer.id}")
    click_link 'complete_quiz'
    accept_dialog
    assert has_content?("Quiz completed ")
    assert has_content?("Rank")
    assert has_content?("1/1")
    click_link 'Logout'
    find('.flash-info:contains("Logged out")')
    login(@candidate)
    visit root_path
    within('#courses') do
      click_link @course.name
    end
    find(".page-header h4:contains('#{@course.name}')")
    within('#content') do
      click_link 'Enroll'
    end
    find('.flash-info:contains("Enrolled")')
    visit root_path
    within('#courses') do
      click_link @course.name
    end
    find(".page-header h4:contains('#{@course.name}')")
    within('.nav-tabs') do
      click_link 'Quizzes'
    end
    find('.nav-tabs li.active a:contains("Quizzes")')
    assert has_content?(@quiz.name)
    click_link @quiz.name
    assert has_content?(@quiz.instruction)
    click_link 'start_quiz'
    accept_dialog
    click_link 'complete_quiz'
    accept_dialog
    assert has_content?("Quiz completed ")
    assert has_content?("Rank")
    assert has_content?("1/2")
  end

  test 'time_limit' do
    @quiz.time_limit_in_minutes = 0.03
    @quiz.save!
    login(@akshi)
    visit root_path
    within('#courses') do
      click_link @course.name
    end
    find(".page-header h4:contains('#{@course.name}')")
    within('.nav-tabs') do
      click_link 'Quizzes'
    end
    find('.nav-tabs li.active a:contains("Quizzes")')
    assert has_content?(@quiz.name)
    click_link @quiz.name
    assert has_content?(@quiz.instruction)
    click_link 'start_quiz'
    accept_dialog
    find("#quiz-timer")
    sleep(3)
    assert has_content?("Quiz completed ")
  end

  test 'allow review' do
    login(@akshi)
    visit root_path
    within('#courses') do
      click_link @course.name
    end
    find(".page-header h4:contains('#{@course.name}')")
    within('.nav-tabs') do
      click_link 'Quizzes'
    end
    find('.nav-tabs li.active a:contains("Quizzes")')
    assert has_content?(@quiz.name)
    click_link @quiz.name
    assert has_content?(@quiz.instruction)
    click_link 'start_quiz'
    accept_dialog
    assert has_content?(@question.content)
    answer = @question.answers.first
    choose("selected-answer_#{answer.id}")
    click_link 'complete_quiz'
    accept_dialog
    assert has_content?("Quiz completed ")
    assert has_content?("Rank")
    assert has_content?("1/1")
    assert has_content?("Review")
  end

  test 'block review' do
    login(@gg)
    visit root_path
    within('#courses') do
      click_link @course.name
    end
    find(".page-header h4:contains('#{@course.name}')")
    within('.nav-tabs') do
      click_link 'Quizzes'
    end
    find('.nav-tabs li.active a:contains("Quizzes")')
    within('#quizzes') do
      find(:css, "#quiz_allow_review").set(false)
      click_button 'Update'
    end
    find('.flash-info:contains("Updated")')
    click_link 'Logout'
    login(@akshi)
    visit root_path
    within('#courses') do
      click_link @course.name
    end
    find(".page-header h4:contains('#{@course.name}')")
    within('.nav-tabs') do
      click_link 'Quizzes'
    end
    find('.nav-tabs li.active a:contains("Quizzes")')
    assert has_content?(@quiz.name)
    click_link @quiz.name
    assert has_content?(@quiz.instruction)
    click_link 'start_quiz'
    accept_dialog
    assert has_content?(@question.content)
    answer = @question.answers.first
    choose("selected-answer_#{answer.id}")
    click_link 'complete_quiz'
    accept_dialog
    assert has_content?("Quiz completed ")
    assert has_content?("Rank")
    assert has_content?("1/1")
    assert has_no_content?("Review")
  end

  
  test 'category quiz' do
    login(@akshi)
    visit root_path
    within('#courses') do
      click_link @course.name
    end
    find(".page-header h4:contains('#{@course.name}')")
    within('.nav-tabs') do
      click_link 'Quizzes'
    end
    find('.nav-tabs li.active a:contains("Quizzes")')
    assert has_content?(@quiz.name)
    click_link 'Zoology'
    assert has_no_content?(@quiz.name)
  end
end
