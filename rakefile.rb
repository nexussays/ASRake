require 'rubygems'
require 'rubygems/package_task'

task :default do
	system "rake --tasks"
end

package = Gem::PackageTask.new Gem::Specification.load('asrake.gemspec') do |pkg|
	pkg.need_zip = false
end

desc "Push gem to rubygems.org"
task :deploy => :package do
	sh "gem push #{package.package_dir}/#{package.name}.gem"
end

desc "Install the gem locally"
task :test => [:package, :uninstall] do
	sh "gem install #{package.package_dir}/#{package.name}.gem"
end

# Save a few key strokes
desc "Uninstall asrake gem"
task :uninstall do
	sh 'gem uninstall asrake'
end