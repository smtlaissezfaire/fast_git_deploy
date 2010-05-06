namespace :deploy do
  namespace :rollback do
    desc "Rolls the app back one revision"
    task :code, :except => { :no_release => true } do
      current_revision  = capture("cat #{version_file}").gsub(/\r?\n?/, "")
      previous_revision = nil

      revision_log_data = capture("cat #{revision_log}").split(/\r?\n/)
      revisions = revision_log_data.map do |entry|
        entry.split(" ").last
      end

      revisions.reverse!

      revisions.each_with_index do |revision, index|
        if current_revision == revision
          # we have found the currently deployed revision
          # so scan the file backwards until a different revision
          # is found (removing duplicates - i.e.):
          #
          # 2010-04-21 15:22:59 deploy 2a285b0f600c7ed31b307390ad91c
          # 2010-04-22 09:58:28 deploy 53cff5db28116ecd5ad32d11ee6e1
          # 2010-04-22 10:02:41 deploy 53cff5db28116ecd5ad32d11ee6e1
          # 2010-04-26 08:18:39 deploy 5494dc2a00beb5350eff6be151987
          # 2010-04-27 09:10:06 deploy 5494dc2a00beb5350eff6be151987
          # 2010-04-27 11:49:29 deploy 5494dc2a00beb5350eff6be151987
          #
          # Rolling back from 5494dc should yield 53cff5db
          previous_revision = revisions[index..revision_log_data.length-1].detect do |rev|
            rev != current_revision
          end
        end
      end

      if previous_revision
        run [
          "cd #{current_path}",
          "#{scm_command} reset --hard #{previous_revision}"
        ].join(" && ")
      else
        raise(Capistrano::Error, "Couldn't find a revision previous to #{current_revision}")
      end
    end

    desc "Rolls back the app one revision, restarts mongrel, and writes the revision to the VERSION file (but not revisions.log)"
    task :default do
      transaction do
        rollback.code
        deploy.restart
        deploy.set_version_file
      end
    end
  end
end