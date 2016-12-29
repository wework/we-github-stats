
# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'we/github_stats/version'

Gem::Specification.new do |spec|
  spec.name          = 'we-github-stats'
  spec.version       = We::GitHubStats::VERSION
  spec.authors       = ['Phil Sturgeon']
  spec.email         = ['phil.sturgeon@wework.com']
  spec.summary       = %q{What did your organization get up to this year}
  spec.description   = %q{Pull basic statistics on the last years worth of commits}
  spec.homepage      = 'https://github.com/wework/we-github-stats'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = ['github_stats']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.12'
  # spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry-byebug'
  spec.add_runtime_dependency 'octokit', '~> 4.0'
  spec.add_runtime_dependency 'terminal-table'
  spec.add_runtime_dependency 'faraday-http-cache'
end
