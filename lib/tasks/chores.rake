namespace :chores do
  desc 'Set default features to courses'
  task :set_default_features => :environment do
    Course.update_all(:features => Course::FEATURES.to_yaml)
  end

  desc 'Add user to course'
  task :add_student_to_courses => :environment do |t, args|
    user = User.find_by_username(ENV['username'])
    courses = Course.where('name like :prefix', :prefix => "%#{ENV['course_name']}%")
    courses.each do |course|
      course.add_student(user)
    end
  end
end
