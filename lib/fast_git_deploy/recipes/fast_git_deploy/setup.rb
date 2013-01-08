module FastGitDeploy
  module Setup
    def self.load_into(configuration)
      configuration.load do
        namespace :deploy do
          namespace :fast_git_setup do
            task :cold do
              clone_repository
              finalize_clone
              create_revision_log

              deploy.update
              deploy.start
            end

            def self.clone_repository_command(path)
              [
                "if [ ! -e #{path} ]",
                  "then mkdir -p #{deploy_to}",
                  "cd #{deploy_to}",
                  "#{scm_command} clone #{repository} #{path}",
                "fi"
              ].join("; ")
            end

            desc "Clones the repos"
            task :clone_repository, :except => { :no_release => true } do
              run clone_repository_command(current_path)
            end

            task :create_revision_log, :except => { :no_release => true } do
              run [
                "if [ ! -e #{revision_log} ]",
                  "then touch #{revision_log}",
                  "chmod 664 #{revision_log}",
                "fi"
              ].join("; ")
            end

            task :warm do
              clone_repository_to_tmp_path

              deploy.web.disable
              remove_old_app
              rename_clone
              finalize_clone
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
                "if [ -e #{deploy_to}/releases ]",
                  "then mv #{deploy_to}/releases #{deploy_to}/releases.old",
                "fi"
              ].join("; ")
            end

            task :remove_current, :except => { :no_release => true } do
              # test -h => symlink
              run [
                "if [ -h #{current_path} ]",
                  "then mv #{current_path} #{current_path}.old",
                "fi"
              ].join("; ")
            end


            desc <<-HERE
              This task will make the release group-writable (if the :group_writable
              variable is set to true, which is the default). It will then set up
              symlinks to the shared directory for the log, system, and tmp/pids
              directories.
            HERE
            task :finalize_clone, :except => { :no_release => true } do
              run "chmod -R g+w #{current_path}" if fetch(:group_writable, true)

              # mkdir -p is making sure that the directories are there for some SCM's that don't
              # save empty folders
              run [
                "rm -rf #{current_path}/log #{current_path}/public/system #{current_path}/tmp/pids",
                "mkdir -p #{current_path}/public",
                "mkdir -p #{current_path}/tmp",
                "ln -s #{shared_path}/log    #{current_path}/log",
                "ln -s #{shared_path}/system #{current_path}/public/system",
                "ln -s #{shared_path}/pids   #{current_path}/tmp/pids"
              ].join(" && ")
            end
          end
        end
      end
    end
  end
end
