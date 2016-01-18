# == Schema Information
#
# Table name: comments
#
#  id         :integer          not null, primary key
#  post_id    :integer
#  content    :text
#  email      :string(255)
#  status     :string(255)      default("review")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#

require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
  end

  test 'presence validation' do
    comment = Comment.new
    assert !comment.save
    assert comment.errors[:email].include?('is required')
    assert comment.errors[:content].include?('is required')
    assert comment.errors[:post_id].include?('is required')
  end

  test 'state' do
    comment = comments(:first_comment)
    assert_equal 'review', comment.status
    comment.reject!
    assert_equal 'rejected', comment.status
    assert !comment.approved?
    comment.review!
    assert_equal 'review', comment.status
    comment.approve!
    assert_equal 'approved', comment.status
    assert comment.approved?
  end

  test 'pagination' do
    100.times do
      Comment.create!(:email => 'gg@akshi.com', :content => random_string(50),
                     :post_id => Post.first.id)
    end
    assert_equal 15, Comment.paginate(:page => 1).size
    assert_equal 15, Comment.paginate(:page => 5).size
  end

  test 'published' do
    Comment.delete_all
    first_comment = second_comment = nil
    assert_difference('Comment.count', 2) do
      first_comment = Comment.create!(:email => 'gg@akshi.com', :content => random_string(50),
                           :post_id => Post.first.id, :status => 'approved')
      second_comment = Comment.create!(:email => 'akshi@akshi.com', :content => random_string(50),
                           :post_id => Post.first.id)
    end
    assert_equal [first_comment], Comment.approved
  end

  test 'review' do
    Comment.delete_all
    first_comment = second_comment = nil
    assert_difference('Comment.count', 2) do
      first_comment = Comment.create!(:email => 'gg@akshi.com', :content => random_string(50),
                           :post_id => Post.first.id, :status => 'published')
      second_comment = Comment.create!(:email => 'akshi@akshi.com', :content => random_string(50),
                           :post_id => Post.first.id)
    end
    assert_equal [second_comment], Comment.review
  end
end
