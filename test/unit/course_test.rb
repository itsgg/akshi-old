# == Schema Information
#
# Table name: courses
#
#  id                          :integer          not null, primary key
#  name                        :string(255)
#  description                 :text(2147483647)
#  category_id                 :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  cover_file_name             :string(255)
#  cover_content_type          :string(255)
#  cover_file_size             :integer
#  cover_updated_at            :datetime
#  average_score               :float            default(0.0), not null
#  status                      :string(255)      default("new")
#  amount                      :float            default(0.0)
#  currency                    :string(255)      default("INR")
#  paid                        :boolean          default(FALSE)
#  offline_payment_instruction :text
#  features                    :text
#  featured                    :boolean          default(FALSE)
#

require 'test_helper'

class CourseTest < ActiveSupport::TestCase
  setup do
    @course_one = Course.create!(:name => 'course_one', :description => random_string(50),
                                 :category_id => Category.first.id, :features => Course::FEATURES)
    @course_two = Course.create!(:name => 'course_two', :description => random_string(50),
                                 :category_id => Category.first.id, :features => Course::FEATURES)
    @gg = users(:gg)
    @akshi = users(:akshi)
  end

  test 'presence validation' do
    course = Course.new
    course.amount = nil
    assert !course.save
    assert course.errors[:name].include?('is required')
    assert course.errors[:amount].include?('is required')
  end

  test 'length validation' do
    course = courses(:eng101)
    course.name = random_string(2)
    assert !course.save
    assert course.errors[:name].include?('min 4 characters')
    course.name = random_string(90)
    assert !course.save
    assert course.errors[:name].include?('max 80 characters')
  end

  test 'payment info validations' do
    course = courses(:eng101)
    course.paid = true
    assert !course.save
    assert course.errors[:currency].include?('is invalid')
    assert course.errors[:amount].include?('must be greater than 0')
  end

  test 'add student' do
    @course_one.add_student(@gg)
    assert @course_one.students.include?(@gg)
    assert @gg.learning_courses.include?(@course_one)
  end

  test 'add teacher' do
    @course_two.add_teacher(@gg)
    assert @course_two.teachers.include?(@gg)
    assert @gg.teaching_courses.include?(@course_two)
  end

  test 'pagination' do
    100.times do
      Course.create!(:name => 'foobar', :description => random_string(50),
                     :category_id => Category.first.id, :features => Course::FEATURES)
    end
    assert_equal 9, Course.paginate(:page => 1).size
    assert_equal 9, Course.paginate(:page => 5).size
  end

  test 'popular' do
    Course.delete_all
    one = Course.create!(:name => 'course_one', :description => random_string(50),
                         :category_id => Category.first.id, :average_score => 3.2, :features => Course::FEATURES)
    two = Course.create!(:name => 'course_two', :description => random_string(50),
                         :category_id => Category.first.id, :average_score => 1.2, :features => Course::FEATURES)
    three = Course.create!(:name => 'course_three', :description => random_string(50),
                         :category_id => Category.first.id, :average_score => 4.2, :features => Course::FEATURES)
    four = Course.create!(:name => 'course_four', :description => random_string(50),
                         :category_id => Category.first.id, :average_score => 5.0, :features => Course::FEATURES)
    assert_equal [four, three, one, two], Course.popular
  end

  test 'publish status' do
    Course.published.each do |course|
      assert course.published?
    end
  end

  test 'average score' do
    math101 = courses(:math101)
    math101.rate!
    assert_equal 4, math101.average_score
  end

  test 'can rate' do
    course = courses(:eng101)
    assert course.can_rate?(@akshi.id)
    assert !course.can_rate?(@gg.id)
    course.ratings = []
    course.save!
    assert course.can_rate?(@akshi.id)
    assert !course.can_rate?(@gg.id)
  end

  test 'rated?' do
    course = courses(:blah102)
    assert !course.rated?(@gg.id)
    course = courses(:comp101)
    assert course.rated?(@gg.id)
  end

  test 'status' do
    course = courses(:math101)
    assert_equal 'new', course.status
    course.review!
    assert_equal 'review', course.status
    course.reject!
    assert_equal 'rejected', course.status
    assert !course.published?
    course.review!
    assert_equal 'review', course.status
    course.publish!
    assert_equal 'published', course.status
    assert course.published?
  end

  test 'filter' do
    # No category specified
    assert_equal @gg.learning_courses.published.popular,
                 Course.filter(@gg, {:type => 'learn'})
    assert_equal @gg.teaching_courses.popular,
                 Course.filter(@gg, {:type => 'teach'})
    # All category specified
    assert_equal @gg.learning_courses.published.popular,
                 Course.filter(@gg, {:type => 'learn', :category => 'All'})
    assert_equal @gg.teaching_courses.popular,
                 Course.filter(@gg, {:type => 'teach', :category => 'All'})
    # None category specified
    assert_equal [courses(:blah101)],
                 Course.filter(@gg, {:type => 'teach', :category => 'None'})
    assert_equal [courses(:blah102)],
                 Course.filter(@gg, {:type => 'learn', :category => 'None'})
    # Valid category specified
    english = categories(:english)
    assert_equal [courses(:eng101)],
                 Course.filter(@gg, {:type => 'teach', :category => english.name})
    assert_equal [],
                 Course.filter(@gg, {:type => 'learn', :category => english.name})
    # Invalid category specified
    assert_equal @gg.learning_courses.published.popular,
                 Course.filter(@gg, {:type => 'learn', :category => 'blah'})
    # Search
    assert_equal [courses(:eng101)], Course.filter(nil, {:q => {'name_or_description_cont' => 'English'}})
    assert_equal [courses(:eng101)], Course.filter(nil, {:q => {'name_or_description_cont' => 'English'}, :category => 'English'})
    assert Course.filter(nil, {:q => {'name_or_description_cont' => 'English'}, :category => 'Mathematics'}).blank?
  end

  test 'feature_enabled?' do
    available_features = ['announcement', 'quiz']
    math = courses(:math101)
    Course::FEATURES.each do |feature|
      assert math.feature_enabled?(feature)
    end
    math.features = available_features
    assert math.save
    available_features.each do |feature|
      assert math.feature_enabled?(feature)
    end
    [Course::FEATURES - available_features].each do |feature|
      assert !math.feature_enabled?(feature)
    end
  end

  test 'validate_features' do
    math = courses(:math101)
    math.features = []
    assert !math.save
    assert math.errors[:features].include?('is required')
    math.features = ['blah']
    assert !math.save
    assert math.errors[:features].include?('is invalid')
  end

end
