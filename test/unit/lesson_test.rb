# == Schema Information
#
# Table name: lessons
#
#  id                  :integer          not null, primary key
#  name                :string(255)
#  course_id           :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  upload_file_name    :string(255)
#  upload_content_type :string(255)
#  upload_file_size    :integer
#  upload_updated_at   :datetime
#  position            :integer
#  content             :text(2147483647)
#  published           :boolean          default(FALSE)
#  subject_id          :integer
#

require 'test_helper'

class LessonTest < ActiveSupport::TestCase
  test 'presence validations' do
    lesson = Lesson.new
    assert !lesson.save
    assert lesson.errors[:name].include?('is required')
    assert lesson.errors[:course_id].include?('is required')
  end

  test 'length validations' do
    lesson = lessons(:calculus)
    lesson.name = random_string(90)
    assert !lesson.save
    assert lesson.errors[:name].include?('max 80 characters')
    lesson.name = random_string(3)
    assert !lesson.save
    assert lesson.errors[:name].include?('min 4 characters')
  end

  test 'uploads' do
    lesson = lessons(:calculus)
    lesson.upload = upload('test.pdf')
    assert lesson.save
    assert_equal lesson.upload_file_name, 'test.pdf'
    assert_equal 'document', lesson.upload_type
    assert_queued DocumentConverter

    lesson.upload = upload('test.m4v')
    assert lesson.save
    assert_equal lesson.upload_file_name, 'test.m4v'
    assert_equal 'media', lesson.upload_type
    assert_queued MediaConverter
  end

  test 'upload type' do
    lesson = lessons(:calculus)
    lesson.upload = upload('test')
    assert lesson.save
    assert_equal lesson.upload_file_name, 'test'
    assert_equal 'file', lesson.upload_type
  end

  test 'delete uploads' do
    lesson = lessons(:calculus)
    lesson.upload = upload('test.pdf')
    assert lesson.save
    assert_equal lesson.upload_file_name, 'test.pdf'
    lesson.delete_attachment!
    assert_queued AttachmentDeleter
  end

  test 'conversion complete' do
    lesson = lessons(:calculus)
    lesson.upload = upload('test.pdf')
    file_path = lesson.upload.path
    FileUtils.touch "#{file_path.chomp(File.extname(file_path))}.converted"
    assert lesson.conversion_complete?
  end

  test 'processed uploads' do
    lesson = lessons(:calculus)
    assert lesson.processed_uploads.blank?
    lesson.upload = upload('test.pdf')
    lesson.save!
    DocumentConverter.perform(lesson.upload.path)
    assert lesson.processed_uploads.present?
  end

  test 'order' do
    calculus = lessons(:calculus)
    statistics = lessons(:statistics)
    math = courses(:math101)
    assert_equal [calculus, statistics], math.lessons
    math.lessons.order!([statistics, calculus].map(&:id))
    assert_equal [statistics, calculus], math.lessons.reload
  end

  test 'normalize filenames' do
    lesson = lessons(:calculus)
    lesson.upload = upload('test. special characters.pdf')
    assert lesson.save
    assert_equal lesson.upload_file_name, 'test._special_characters.pdf'
    assert_equal 'document', lesson.upload_type
    assert_queued DocumentConverter
  end

  test 'filter' do
    math = courses(:math101)
    calculus = lessons(:calculus)
    calculus.upload = upload('test.pdf')
    assert calculus.save
    statistics = lessons(:statistics)
    statistics.upload = upload('test.m4v')
    assert statistics.save
    [calculus, statistics].each do |lesson|
      math.lessons.filter('All').include?(lesson)
    end
    assert_equal math.lessons.filter('Document'), [calculus]
    assert_equal math.lessons.filter('Media'), [statistics]
    [calculus, statistics].each do |lesson|
      math.lessons.filter().include?(lesson)
    end
    [calculus, statistics].each do |lesson|
      math.lessons.filter(nil).include?(lesson)
    end
  end
end
