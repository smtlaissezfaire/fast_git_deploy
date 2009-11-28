namespace :deploy do
  namespace :git_setup do
    desc <<-DESC
      Sets up git-based deploys.  Removes the current app if it already exists.
      Creates the repos. Creates the revision log if it doesn't exist.

      This task disables the site before it runs - so make sure you are ready to make
      the leap! (test it on staging, first)
    DESC
    task :default, :except => { :no_release => true } do
      deploy.web.disable
      remove_app
      clone_repository
      create_revision_log
    end

    task :remove_app do
      remove_releases
      remove_current
    end

    task :remove_releases do
      run [
        "if [[ -e #{deploy_to}/releases ]]",
          "then mv #{deploy_to}/releases #{deploy_to}/releases.old",
        "fi"
      ].join("; ")
    end

    task :remove_current do
      run [
        "if [[ -e #{current_path} ]]",
          "then mv #{current_path} #{current_path}.old",
        "fi"
      ].join("; ")
    end

    desc "Clones the repos"
    task :clone_repository, :except => { :no_release => true } do
      run [
        "if [[ ! -e #{current_path} ]]",
          "then mkdir -p #{deploy_to}",
          "cd #{deploy_to}",
          "git clone #{repository} #{current_path}",
        "fi"
      ].join("; ")
    end

    task :create_revision_log, :except => { :no_release => true } do
      run [
        "if [[ ! -e #{revision_log} ]]",
          "then touch #{revision_log}",
          "chmod 664 #{revision_log}",
        "fi"
      ].join("; ")
    end
  end
end