def self.join(*args)
  current_path = File.dirname(__FILE__)
  File.expand_path(File.join(current_path, *args))
end

set :application, "fast_git_deploy_test"
set :repository,  join("..", "..", ".git")
set :deploy_to,   join("..", "deployments")
set :scm_command, `which git`.chomp
set :user,        `whoami`.chomp

set :scm, :git

ssh_options[:paranoid] = false
default_run_options[:pty] = true

role :web, "127.0.0.1"
role :app, "127.0.0.1"
role :db,  "127.0.0.1", :primary => true

set :branch, "master"

namespace :deploy do
  task :restart do
    # do nothing
  end

  task :migrate do
    # do nothing
  end

  task :start do
    # do nothing
  end
end