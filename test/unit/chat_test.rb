# == Schema Information
#
# Table name: chats
#
#  id         :integer          not null, primary key
#  content    :text(2147483647)
#  course_id  :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class ChatTest < ActiveSupport::TestCase
  test 'presence validations' do
    chat = Chat.new
    assert !chat.save
    assert chat.errors[:content].include?('is required')
  end
end
