
if defined?(Capistrano) &&
  Capistrano::Configuration.respond_to?(:instance) &&
  instance = Capistrano::Configuration.instance

  require File.dirname(__FILE__) + "/fast_git_deploy/recipes/fast_git_deploy"
  require File.dirname(__FILE__) + "/fast_git_deploy/recipes/fast_git_deploy/rollback"
  require File.dirname(__FILE__) + "/fast_git_deploy/recipes/fast_git_deploy/setup"

  FastGitDeploy::Main.load_into(instance)
  FastGitDeploy::Rollback.load_into(instance)
  FastGitDeploy::Setup.load_into(instance)
end


