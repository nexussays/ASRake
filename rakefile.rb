require 'bundler/gem_tasks'

task :default do
	system "rake --tasks"
end

desc "Remove packaged gem"
task :clobber do
	rm_rf 'pkg'
end