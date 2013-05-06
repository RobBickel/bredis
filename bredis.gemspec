# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'bredis/version'

Gem::Specification.new do |spec|
  spec.name        = "bredis"
  spec.version     = Bredis::VERSION
  spec.date        = Time.now.strftime('%Y-%m-%d')
  spec.authors     = ["Schubert Cardozo"]
  spec.email       = ["cardozoschubert@gmail.com"]
  spec.homepage    = "https://github.com/saturnine/bredis"
  spec.summary     = %q{A business rule engine that sits inside redis}
  spec.description = %q{A business rule engine that sits inside redis}

  spec.rubyforge_project = "bredis"

  spec.files          = Dir.glob("**/*")

  spec.require_paths  = ["lib"]

  spec.add_runtime_dependency('acts_as_hashish', '>= 0.4.3')

  spec.add_development_dependency('rake', '>= 10.0.3')
  spec.add_development_dependency('rspec', '>= 2.11.0')
  spec.add_development_dependency('mocha', '>= 0.12.7')
  spec.add_development_dependency('simplecov', '>= 0.7.1')
  spec.add_development_dependency('coveralls', '>= 0.6.7')

  spec.required_ruby_version = '>= 1.9.2'
end
