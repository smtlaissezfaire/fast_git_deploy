namespace :deploy do
  namespace :git_setup do
    task :cold do
      clone_repository
      create_revision_log

      deploy.update
      deploy.restart
    end

    def self.clone_repository_command(path)
      [
        "if [[ ! -e #{path} ]]",
          "then mkdir -p #{deploy_to}",
          "cd #{deploy_to}",
          "git clone #{repository} #{path}",
        "fi"
      ].join("; ")
    end

    desc "Clones the repos"
    task :clone_repository, :except => { :no_release => true } do
      run clone_repository_command(current_path)
    end

    task :create_revision_log, :except => { :no_release => true } do
      run [
        "if [[ ! -e #{revision_log} ]]",
          "then touch #{revision_log}",
          "chmod 664 #{revision_log}",
        "fi"
      ].join("; ")
    end

    task :migrate do
      clone_repository_to_tmp_path

      deploy.web.disable
      remove_old_app
      rename_clone
      deploy.default
      deploy.web.enable
    end

    task :clone_repository_to_tmp_path, :except => { :no_release => true } do
      run clone_repository_command("#{current_path}.clone")
    end

    task :rename_clone, :except => { :no_release => true } do
      run "mv #{current_path}.clone #{current_path}"
    end

    task :remove_old_app do
      remove_releases
      remove_current
    end

    task :remove_releases, :except => { :no_release => true } do
      run [
        "if [[ -e #{deploy_to}/releases ]]",
          "then mv #{deploy_to}/releases #{deploy_to}/releases.old",
        "fi"
      ].join("; ")
    end

    task :remove_current, :except => { :no_release => true } do
      # test -h => symlink
      run [
        "if [[ -h #{current_path} ]]",
          "then mv #{current_path} #{current_path}.old",
        "fi"
      ].join("; ")
    end
  end
end