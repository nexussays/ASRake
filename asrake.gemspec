# -*- encoding: utf-8 -*-
Gem::Specification.new do |spec|
	spec.name        = 'asrake'
	spec.version     = '0.14.0'
	spec.platform	  = Gem::Platform::RUBY
	
	spec.authors     = ["Malachi Griffie"]
	spec.email       = ["malachi@nexussays.com"]
	spec.homepage    = 'https://github.com/nexussays/ASRake'
	spec.license     = 'MIT'

	spec.summary     = <<DESC
A cross-platform Rake library to quickly and easily create build scripts for
Actionscript 3, Flex, and AIR projects.
DESC
	spec.description = <<DESC
A Rake library for Actionscript 3, Flex, and AIR projects.
See full documentation at https://github.com/nexussays/ASRake/blob/master/README.md
DESC

	spec.files       = Dir['lib/**/*.rb'] + %w[LICENSE README.md asrake.gemspec Gemfile]

	spec.add_dependency 'rake', '>= 0.9', '< 11.0'
	spec.add_runtime_dependency 'nokogiri', '~> 1.5'
	spec.add_runtime_dependency 'rubyzip', '~> 0.9'
end