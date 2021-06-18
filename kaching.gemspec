# frozen_string_literal: true

require_relative 'lib/kaching/version'

Gem::Specification.new do |spec|
  spec.name          = 'kaching'
  spec.version       = Kaching::VERSION
  spec.authors       = ['Aaron Madlon-Kay']
  spec.email         = ['aaron@madlon-kay.com']

  spec.summary       = 'Monitor sales on the App Store and Google Play'
  spec.homepage      = 'https://github.com/amake/kaching'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/amake/kaching'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'app_store_connect'
  spec.add_dependency 'google-cloud-storage'
  spec.add_dependency 'open_exchange_rates'
  spec.add_dependency 'rubyzip'

  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-minitest'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'solargraph'
end
