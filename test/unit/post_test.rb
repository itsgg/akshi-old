# == Schema Information
#
# Table name: posts
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  content    :text(2147483647)
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class PostTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
  end

  test 'length validation' do
    post = posts(:post_one)
    post.title = random_string(2)
    assert !post.save
    assert post.errors[:title].include?('min 4 characters')
    post.title = random_string(90)
    assert !post.save
    assert post.errors[:title].include?('max 80 characters')
  end

  test 'presence validation' do
    post = Post.new
    assert !post.save
    assert post.errors[:title].include?('is required')
    assert post.errors[:content].include?('is required')
    assert post.errors[:user_id].include?('is required')
  end

  test 'pagination' do
    100.times do
      Post.create! :title => 'foobar', :content => random_string(50),
                   :user_id => User.first.id
    end
    assert_equal 15, Post.paginate(:page => 1).size
    assert_equal 15, Post.paginate(:page => 5).size
  end

  test 'brief_content' do
    post = Post.create! :title => 'hello', :content => 'hello <b>world</b>.',
                        :user_id => User.first.id
    assert_equal 'hello world.', post.brief_content
  end
end
