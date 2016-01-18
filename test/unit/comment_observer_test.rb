require 'test_helper'

class CommentObserverTest < ActiveSupport::TestCase
  setup do
    @post = posts(:post_one)
    @comment = comments(:first_comment)
    @gg = users(:gg)
    @admin = users(:admin)
  end

  test 'observable Comment Model' do
    assert_equal Comment, CommentObserver.observed_class
  end
end
