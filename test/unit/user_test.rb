# == Schema Information
#
# Table name: users
#
#  id                   :integer          not null, primary key
#  username             :string(255)
#  fullname             :string(255)
#  email                :string(255)
#  about                :text(2147483647)
#  password_digest      :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  avatar_file_name     :string(255)
#  avatar_content_type  :string(255)
#  avatar_file_size     :integer
#  avatar_updated_at    :datetime
#  reset_password_token :string(255)
#  authentication_token :string(255)
#  announcement_notify  :boolean          default(TRUE)
#  admin                :boolean          default(FALSE)
#  discussion_notify    :boolean          default(TRUE)
#  blocked              :boolean          default(FALSE)
#  session_id           :text
#  schedule_notify      :boolean          default(TRUE)
#  phone_number         :string(255)
#  state_city           :string(255)
#  institution          :string(255)
#  date_of_birth        :string(255)
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @gg = users(:gg)
  end

  test 'presence validation' do
    user = User.new
    assert !user.save
    assert user.errors[:username].include?('is required')
    assert user.errors[:password].include?('is required')
    assert user.errors[:fullname].include?('is required')
    assert user.errors[:email].include?('is required')
    @gg.password = nil
    assert @gg.save
    @gg.password_required = true
    assert !@gg.save
    assert user.errors[:password].include?('is required')
  end

  test 'unique validation' do
    user = User.new(:username => 'gg', :email => 'gg@akshi.com')
    assert !user.save
    assert user.errors[:username].include?('is taken')
    assert user.errors[:email].include?('is taken')
  end

  test 'length validation' do
    @gg.username = random_string(1)
    assert !@gg.save
    assert @gg.errors[:username].include?('min 2 characters')
    @gg.username = random_string(20)
    assert !@gg.save
    assert @gg.errors[:username].include?('max 15 characters')
    @gg.password = random_string(2)
    assert !@gg.save
    assert @gg.errors[:password].include?('min 4 characters')
    @gg.password = random_string(30)
    assert !@gg.save
    assert @gg.errors[:password].include?('max 20 characters')
    @gg.fullname = random_string(1)
    assert !@gg.save
    assert @gg.errors[:fullname].include?('min 2 characters')
    @gg.fullname = random_string(90)
    assert !@gg.save
    assert @gg.errors[:fullname].include?('max 80 characters')
  end

  test 'format validation' do
    @gg.email = random_string(3)
    assert !@gg.save
    assert @gg.errors[:email].include?('is invalid')
  end

  test 'confirmation validation' do
    @gg.password = 'foo'
    @gg.password_confirmation = 'bar'
    assert !@gg.save
    assert @gg.errors[:password].include?("doesn't match")
  end

  test 'authentication' do
    assert @gg.authenticate('password')
    assert !@gg.authenticate('foobar')
  end

  test 'teacher?/student?' do
    assert @gg.teacher?(courses(:eng101).id)
    assert @gg.student?(courses(:comp101).id)
  end

  test 'reset password' do
    assert_difference('ActionMailer::Base.deliveries.size', 1) do
      @gg.reset_password!
    end
    assert_not_nil @gg.reset_password_token
    reset_email = ActionMailer::Base.deliveries.last
    assert_equal 'Akshi - Password reset instruction', reset_email.subject
    assert_equal @gg.email, reset_email.to[0]
    assert_match Regexp.new("Hi #{@gg.fullname}"), reset_email.encoded
    assert_match Regexp.new("/users/#{@gg.to_param}/reset_password"), reset_email.encoded
    assert_match Regexp.new(@gg.reset_password_token), reset_email.encoded
  end

  test 'avatar errors' do
    @gg.errors.add(:avatar_file_size, 'test error')
    assert @gg.avatar_errors?
  end

  test 'brief about' do
    @gg.about = nil
    assert_nil @gg.brief_about
    @gg.about = '<b>hello</b> <img src="#" />world'
    assert_equal 'hello world', @gg.brief_about
  end

  test 'authentication_token' do
    user = User.new(:username => 'foobar', :password => 'foobar',
                    :password_confirmation => 'foobar',
                    :email => 'foobar@akshi.com', :fullname => 'foobar')
    assert user.save
    assert user.authentication_token.present?
  end
end
