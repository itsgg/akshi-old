# == Schema Information
#
# Table name: topics
#
#  id         :integer          not null, primary key
#  content    :text(2147483647)
#  course_id  :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  parent_id  :integer
#  title      :string(255)
#  subject_id :integer
#

require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  setup do
    @course = courses(:math101)
    @one = topics(:one)
  end

  test 'presence validations' do
    topic = Topic.new
    assert !topic.save
    assert topic.errors[:title].include?('is required')
    assert topic.errors[:content].include?('is required')
    assert topic.errors[:course_id].include?('is required')
    assert topic.errors[:user_id].include?('is required')
    topic.parent_id = topics(:two).id
    assert !topic.save
    assert !topic.errors[:title].include?('is required')
  end

  test 'length validation' do
    topic = topics(:one)
    topic.title = random_string(2)
    assert !topic.save
    assert topic.errors[:title].include?('min 4 characters')
    topic.title = random_string(90)
    assert !topic.save
    assert topic.errors[:title].include?('max 80 characters')
  end

  test 'topic observer root topic' do
    assert_no_difference('ActionMailer::Base.deliveries.size') do
      Topic.create :title => 'blah', :content => 'blah',
                   :course_id => @course.id, :user_id => users(:gg).id
    end
    assert_difference('ActionMailer::Base.deliveries.size', 1) do
      Topic.create :title => 'blah', :content => 'blah',
                   :course_id => @course.id, :user_id => users(:akshi).id
    end
  end

  test 'topic observer reply topic' do
    assert_difference('ActionMailer::Base.deliveries.size', 2) do
      Topic.create :title => 'blah', :content => 'blah',
                   :course_id => courses(:comp101).id, :user_id => users(:admin).id,
                   :parent_id => topics(:five).id
    end
  end

  test 'replies' do
    assert_equal topics(:one_one).parent, topics(:one)
    assert_equal topics(:one_two).parent, topics(:one)
    assert_equal topics(:one).children, [topics(:one_one), topics(:one_two)]
  end
end
