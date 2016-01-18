namespace :notification do
  desc 'Send hourly schedule notifications'
  task :hourly_schedule_notification => :environment do
    schedules = Schedule.active.upcoming
    schedules.each do |schedule|
      time_to_class = schedule.start_time - Time.now
      if time_to_class > 0 && time_to_class < 1.hour
        course = schedule.course
        users = course.users
        users.each do |user|
          if user.schedule_notify?
            UserMailer.send_schedule(user.id, schedule.id).deliver
          end
        end
      end
    end
  end

  desc 'Send daily schedule notifications'
  task :daily_schedule_notification => :environment do
    schedules = Schedule.active.upcoming
    schedules.each do |schedule|
      time_to_class = schedule.start_time - Time.now
      if time_to_class > 1.hour && time_to_class < 1.day
        course = schedule.course
        users = course.users
        users.each do |user|
          if user.schedule_notify?
            UserMailer.send_schedule(user.id, schedule.id).deliver
          end
        end
      end
    end
  end
end
