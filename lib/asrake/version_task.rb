require 'rake/tasklib'

require 'asrake/version/version'

module ASRake
class VersionTask < Rake::TaskLib

	attr_accessor :filename
	attr_accessor :filetype
	attr_reader :version

	def initialize(name = :version, filename = "VERSION")
		self.filename = filename

		yield self if block_given?

		# fail if no filename was provided
		fail "You must define 'filename' for #{self}" if filename == nil

		@path = Pathname.new(self.filename)
		# set filetype from the filename if it hasn't been set already
		self.filetype ||= @path.extname[1..-1]

		# read in the current version
		contents = @path.read rescue '0.0.0'
		@version = case filetype.to_s
			when ''		then Version.to_version(contents.chomp)
			when 'yml'	then Version.to_version(YAML::load(contents))
		end

		# create the primary version task
		desc "Increment version from #{@version}"
		@version_task = Rake::Task.define_task name

		# if the task name is a hash (ie, has dependencies defined) make sure we pull out the task name from it
		name, _ = name.first if name.is_a? Hash

		Rake::Task.define_task name, [:part] => filename do |t, args|
			case (args[:part] || "").chomp.downcase
				when 'major'
					puts "Incremented version from #{@version} to #{save(@version.bump!(:major))}"
				when 'minor'
					puts "Incremented version from #{@version} to #{save(@version.bump!(:minor))}"
				when 'revision', 'rev', 'patch'
					puts "Incremented version from #{@version} to #{save(@version.bump!(:revision))}"
				when ''
					puts "Current version is #{@version}"
					puts "Version number format is Major.Minor.Revision (aka Major.Minor.Patch)"
					puts "To increment the version, provide the respective part as an argument."
					puts "rake #{@version_task}[major]    => #{@version.bump(:major)}"
					puts "rake #{@version_task}[minor]    => #{@version.bump(:minor)}"
					puts "rake #{@version_task}[revision] => #{@version.bump(:revision)}"
				else
					fail "Invalid version argument '#{args[:part]}', run 'rake #{@version_task}' for help."
			end
			@sync_task.execute()
		end

		file filename do
			puts "Created version #{save(Version.to_version(ENV['VERSION'] || '0.0.0'))} at #{filename}"
		end
		
		# create a namespace with the same name as the task to provide further options
		namespace name do

			#add to this task to perform some operation post-bump
			@sync_task = task :sync

		end

	end
	
	private 

	def save(version)
		@path.open('w') do |file|
			file << case filetype.to_s
				when ''		then version.to_s + "\n"
				when 'yml'	then version.to_yaml
			end
		end
		return version
	end
end
end