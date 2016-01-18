require 'test_helper'

class TopicsHelperTest < ActionView::TestCase
  setup do
    @gg = users(:gg)
  end

  test 'topic_nav_link' do
    topic = topics(:one)
    output = topic_nav_link(topic, @gg)
    assert output.include?('Posted by Teacher')
    assert output.include?('<strong>') # Unread
  end
end
