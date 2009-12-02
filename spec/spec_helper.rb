require 'capistrano/cli'
require 'capistrano/configuration'

# load File.expand_path(File.dirname(__FILE__) + "/../recipes/fast_git_deploy.rb")

# load File.dirname(__FILE__) + '/config/deploy.rb'

Spec::Runner.configure do |config|
  config.before :each do
    FileUtils.rm_rf(File.dirname(__FILE__) + "/deployments")
  end

  config.after :each do
    FileUtils.rm_rf(File.dirname(__FILE__) + "/deployments")
  end
end

module Capistrano
  class Configuration
    module Actions
      module Invocation
        def sudo(*parameters, &block)
          options = parameters.last.is_a?(Hash) ? parameters.pop.dup : {}
          command = parameters.first
          user = options[:as] && "-u #{options.delete(:as)}"

          sudo_prompt_option = "-p '#{sudo_prompt}'" unless sudo_prompt.empty?
          sudo_command = [fetch(:sudo, "sudo"), sudo_prompt_option, user].compact.join(" ")

          if command
            run(command, options, &block)
          else
            return sudo_command
          end
        end
      end
    end
  end
end