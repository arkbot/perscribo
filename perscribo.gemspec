# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'perscribo/version'

Gem::Specification.new do |spec|
  spec.name          = 'perscribo'
  spec.version       = Perscribo::VERSION
  spec.authors       = ['Adam Eberlin']
  spec.email         = ['ae@adameberlin.com']
  spec.summary       = 'One logger to rule them all.'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/arkbot/perscribo'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'cucumber', '~> 1.3.17'
  spec.add_development_dependency 'guard', '~> 2.6.1'
  spec.add_development_dependency 'guard-perscribo', '~> 0.0.1'
  spec.add_development_dependency 'guard-cucumber', '~> 1.4.1'
  spec.add_development_dependency 'guard-rspec', '~> 4.3.1'
  spec.add_development_dependency 'guard-rubocop', '~> 1.1.0'
  spec.add_development_dependency 'guard-shell', '~> 0.6.1'
  spec.add_development_dependency 'perscribo-cucumber', '~> 0.0.1'
  spec.add_development_dependency 'perscribo-rspec', '~> 0.0.1'
  spec.add_development_dependency 'perscribo-rubocop', '~> 0.0.1'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.1.0'
  spec.add_development_dependency 'rubocop', '~> 0.26.1'
  spec.add_development_dependency 'terminal-notifier-guard', '~> 1.5.3'

  spec.add_dependency 'rubyisms', '~> 0.0.1'

  # TODO: Not sure how to make these platform-specific dependencies..
  # spec.add_dependency 'rb-inotify', '~> 0.9.5'
  # spec.add_dependency 'rb-kqueue', '~> 0.2.3'
end
