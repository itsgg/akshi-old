namespace :db do
  desc 'Resets the whole databse'
  task :nuke do
    `rake db:drop; rake db:create; rake db:migrate; rake db:fixtures:load;`
    `bundle exec annotate; rake db:test:prepare`
  end
end
