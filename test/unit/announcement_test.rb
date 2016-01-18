# == Schema Information
#
# Table name: announcements
#
#  id         :integer          not null, primary key
#  content    :text(2147483647)
#  course_id  :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  subject_id :integer
#

require 'test_helper'

class AnnouncementTest < ActiveSupport::TestCase
  setup do
    @gg = users(:gg)
    @gg.announcement_notify = true
    @gg.save!
    @course = courses(:math101)
    ActionMailer::Base.deliveries = []
  end

  test 'presence validation' do
    announcement = Announcement.new
    assert !announcement.save
    assert announcement.errors[:content].include?('is required')
    assert announcement.errors[:user_id].include?('is required')
    assert announcement.errors[:course_id].include?('is required')
  end

  test 'default order' do
    Announcement.delete_all
    one = two = nil
    assert_difference('Announcement.count', 2) do
      one = Announcement.create!(:content => 'one', :course_id => @course.id,
                                 :user_id => @gg.id)
      sleep(1)
      two = Announcement.create!(:content => 'two', :course_id => @course.id,
                                 :user_id => @gg.id)
    end
    assert_equal [two, one], @course.announcements.all
  end

  test 'notification to all students' do
    announcement = Announcement.create!(:content => 'Test announcement',
                                        :course_id => @course.id, :user_id => @gg.id)
    assert_equal @course.students.size, ActionMailer::Base.deliveries.size
    assert_match Regexp.new(announcement.brief_content), ActionMailer::Base.deliveries.last.encoded
  end
end
