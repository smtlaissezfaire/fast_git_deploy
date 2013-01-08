# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fast_git_deploy/version'

Gem::Specification.new do |gem|
  gem.name          = "fast_git_deploy"
  gem.version       = FastGitDeploy::VERSION::STRING
  gem.authors       = ["Scott Taylor"]
  gem.email         = ["scott@railsnewbie.com"]
  gem.description   = %q{The Fast Git Deploy Method - just a git reset --hard to update code}
  gem.summary       = <<-HERE
Amazingly fast git deploys by using only a current directory (using git as the version the control history).

It's the same technique github uses at their company.
HERE
  gem.homepage      = "http://github.com/smtlaissezfaire/fast_git_deploy"
  gem.files         = `git ls-files`.split($/)
  # gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  # gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
