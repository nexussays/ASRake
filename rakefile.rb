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
task :install => [:package, :uninstall] do
	run "gem install #{@gem.package_dir}/#{@gem.name}.gem"
end

# Save a few key strokes
desc "Uninstall asrake gem"
task :uninstall do
	run 'gem uninstall asrake'
end