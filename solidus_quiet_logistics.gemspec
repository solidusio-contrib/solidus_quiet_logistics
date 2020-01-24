# frozen_string_literal: true

$:.push File.expand_path('lib', __dir__)
require 'solidus_quiet_logistics/version'

Gem::Specification.new do |s|
  s.name        = 'solidus_quiet_logistics'
  s.version     = SolidusQuietLogistics::VERSION
  s.summary     = 'Solidus Quiet Logistics integration'
  s.description = s.summary
  s.license     = 'BSD-3-Clause'

  s.required_ruby_version = '~> 2.4'

  s.author    = 'Andrea Vassallo'
  s.email     = 'andreavassallo@nebulab.it'
  s.homepage  = 'https://github.com/solidusio-contrib/solidus_quiet_logistics'

  s.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  s.test_files = Dir['spec/**/*']
  s.bindir = "exe"
  s.executables = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  if s.respond_to?(:metadata)
    s.metadata["homepage_uri"] = s.homepage if s.homepage
    s.metadata["source_code_uri"] = s.homepage if s.homepage
  end

  s.add_dependency 'aws-sdk', '~> 3'
  s.add_dependency 'deface', '~> 1.3'
  s.add_dependency 'solidus', ['>= 1.1', '< 3']
  s.add_dependency 'solidus_support', '~> 0.4.0'

  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'solidus_dev_support'
end
