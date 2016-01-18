# == Schema Information
#
# Table name: schedules
#
#  id          :integer          not null, primary key
#  description :string(255)
#  start_time  :datetime
#  course_id   :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  mode        :string(255)      default("LIVE")
#  lesson_id   :integer
#

require 'test_helper'

class ScheduleTest < ActiveSupport::TestCase

  test 'presence validation' do
    schedule = Schedule.new
    assert !schedule.save
    assert schedule.errors[:description].include?('is required')
    assert schedule.errors[:start_time].include?('is required')
    assert schedule.errors[:course_id].include?('is required')
  end

  test 'active' do
    [schedules(:one), schedules(:three)].each do |schedule|
      Schedule.active.include?(schedule)
    end
  end
end
