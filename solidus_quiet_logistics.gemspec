# frozen_string_literal: true

$:.push File.expand_path('lib', __dir__)
require 'solidus_quiet_logistics/version'

Gem::Specification.new do |s|
  s.name        = 'solidus_quiet_logistics'
  s.version     = SolidusQuietLogistics::VERSION
  s.summary     = 'Solidus Quiet Logistics integration'
  s.description = s.summary

  s.required_ruby_version = ">= 2.1"

  s.author    = 'Andrea Vassallo'
  s.email     = 'andreavassallo@nebulab.it'
  s.homepage  = 'https://github.com/nebulab/solidus_quiet_logistics'

  s.files = Dir["{app,config,db,lib}/**/*", 'LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'aws-sdk', '~> 3'
  s.add_dependency 'deface', '~> 1.3'
  s.add_dependency 'solidus', ['>= 1.1', '< 3']

  s.add_development_dependency 'solidus_extension_dev_tools'
end
