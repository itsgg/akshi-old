require 'bundler/capistrano'
require 'capistrano-db-tasks'

set :application, 'akshi'
set :repository,  'git@github.com:itsgg/Akshi.git'
set :shared_children, shared_children + %w{data}
set :use_sudo, false
set :git_enable_submodules, 1
set :keep_releases, 3

set :scm, :git
set :user, :deployer
set :db_local_clean, true

role :web, 'akshi.com'
role :app, 'akshi.com'
role :db,  'akshi.com', :primary => true
set :branch, :master

ssh_options[:forward_agent] = true
default_run_options[:pty] = true

namespace :deploy do
  task :restart, :roles => :app, :except => {:no_release => true} do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  task :symlink_config, :roles => :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/application.yml #{release_path}/config/application.yml"
  end

  after "deploy:finalize_update", "deploy:symlink_config"
end

namespace :foreman do
  desc 'Start foreman services'
  task :start, :roles => :app do
    sudo 'start akshi'
  end

  desc 'Stop foreman services'
  task :stop, :roles => :app do
    sudo 'stop akshi'
  end

  desc 'Restart foreman services'
  task :restart, :roles => :app do
    sudo 'stop akshi'
    sudo 'start akshi'
  end
end

after 'deploy:update', 'foreman:stop'

require './config/boot'
require 'airbrake/capistrano'

after 'deploy:update', 'deploy:cleanup'

