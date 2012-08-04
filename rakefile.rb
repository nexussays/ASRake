require './lib/asrake/host'
require 'rubygems'
require 'rubygems/package_task'

@gem = Gem::PackageTask.new Gem::Specification.load('asrake.gemspec') do |pkg|
	pkg.need_zip = false
end

desc "Push gem to rubygems.org"
task :deploy => :package do
	run "gem push #{@gem.package_dir}/#{@gem.name}.gem"
end

desc "Install the gem locally"
task :install => :package do
	run 'gem uninstall asrake'
	run "gem install #{@gem.package_dir}/#{@gem.name}.gem"
end