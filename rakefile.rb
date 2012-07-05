require './lib/asrake'
require 'rubygems'
require 'rubygems/package_task'

gem = Gem::PackageTask.new Gem::Specification.load('asrake.gemspec') do |pkg|
	pkg.need_zip = false
end

desc "Push gem to rubygems.org"
task :deploy => :package do
	run "gem push #{gem.package_dir}/#{gem.name}.gem", false
end