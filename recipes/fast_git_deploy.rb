current_dir = File.dirname(__FILE__)

load "#{current_dir}/fast_git_deploy/setup.rb"
load "#{current_dir}/fast_git_deploy/rollback.rb"

set(:revision_log) { "#{deploy_to}/revisions.log" }
set(:version_file) { "#{current_path}/REVISION" }

set :migrate_target, :current

namespace :deploy do
  desc <<-DESC
    Deploy a "cold" application (deploy the app for the first time).
  DESC
  task :cold do
    fast_git_setup.cold
  end

  desc <<-DESC
    Deploy a "warm" application - one which is already running, but was
    setup with deploy:cold provided by capistrano's default tasks
  DESC
  task :warm do
    fast_git_setup.warm
  end

  desc <<-DESC
    Deploy and run pending migrations. This will work similarly to the
    `deploy' task, but will also run any pending migrations (via the
    `deploy:migrate' task) prior to updating the symlink. Note that the
    update in this case it is not atomic, and transactions are not used,
    because migrations are not guaranteed to be reversible.
  DESC
  task :migrations do
    set :migrate_target, :current
    update_code
    migrate
    symlink
    restart
  end

  desc "Updates code in the repos by fetching and resetting to the latest in the branch"
  task :update_code, :except => { :no_release => true } do
    run [
      "cd #{current_path}",
      "#{scm_command} fetch",
      "#{scm_command} reset --hard origin/#{branch}"
    ].join(" && ")

    finalize_update
  end

  desc <<-DESC
    [internal] Touches up the released code. This is called by update_code
    after the basic deploy finishes. It assumes a Rails project was deployed,
    so if you are deploying something else, you may want to override this
    task with your own environment's requirements.

    This will touch all assets in public/images,
    public/stylesheets, and public/javascripts so that the times are
    consistent (so that asset timestamping works).  This touch process
    is only carried out if the :normalize_asset_timestamps variable is
    set to true, which is the default.
  DESC
  task :finalize_update, :except => { :no_release => true } do
    if fetch(:normalize_asset_timestamps, true)
      stamp = Time.now.utc.strftime("%Y%m%d%H%M.%S")
      asset_paths = %w(images stylesheets javascripts).map { |p| "#{current_path}/public/#{p}" }.join(" ")
      run "find #{asset_paths} -exec touch -t #{stamp} {} ';'; true", :env => { "TZ" => "UTC" }
    end
  end

  desc "Instead of symlinking, set the revisions file.  This allows us to go back to previous versions."
  task :symlink, :except => { :no_release => true } do
    set_revisions
  end

  task :set_revisions, :except => { :no_release => true } do
    set_version_file
    update_revisions_log
  end

  task :set_version_file, :except => { :no_release => true } do
    run [
      "cd #{current_path}",
      "git rev-list origin/#{branch} | head -n 1 > #{version_file}"
    ].join(" && ")
  end

  task :update_revisions_log, :except => { :no_release => true } do
    run "echo `date +\"%Y-%m-%d %H:%M:%S\"` $USER $(cat #{version_file}) #{File.basename(release_path)} >> #{deploy_to}/revisions.log"
  end
end