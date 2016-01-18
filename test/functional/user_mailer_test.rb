require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test 'reset password' do
    gg = users(:gg)
    mail = UserMailer.reset_password(gg)
    assert_equal "Akshi - Password reset instruction", mail.subject
    assert_equal [gg.email], mail.to
    assert_equal ["admin@akshi.com"], mail.from
    assert_match /reset_password/, mail.encoded
  end

  test 'discussion notification' do
    gg = users(:gg)
    topic = topics(:one)
    mail = UserMailer.send_discussion(gg.id, topic.id)
    assert_equal "Akshi - Discussion notification", mail.subject
    assert_equal [gg.email], mail.to
    assert_equal ["admin@akshi.com"], mail.from
    assert_match /Go to the post/, mail.encoded
  end
end
