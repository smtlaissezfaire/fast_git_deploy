namespace :deploy do
  namespace :rollback do
    desc "Rolls the app back one revision"
    task :code, :except => { :no_release => true } do
      # use tac (the equivalent of tail -r on *BSD) to find the revisions in reverse -
      # If an app has been deployed multiple times under the same revision, we'll use
      # the latest one
      previous_revision = [
        "tac #{revision_log}",
        "grep --before-context 1 $(cat #{version_file})",
        "head -n 1",
        "cut -d ' ' -f 4"
      ].join(" | ")

      run [
        "cd #{current_path}",
        "git fetch",
        "git reset --hard $(#{previous_revision})"
      ].join(" && ")
    end

    desc "Rolls back the app one revision, restarts mongrel, and writes the revision to the VERSION file (but not revisions.log)"
    task :default do
      rollback.code
      deploy.restart
      deploy.set_version_file
    end
  end
end