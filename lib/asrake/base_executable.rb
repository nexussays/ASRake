require 'asrake/util'
require 'asrake/exe_task'

module ASRake
class BaseExecutable

	include Rake::DSL

	#
	# output file or directory
	#
	
	attr_reader :output
	attr_reader :output_file
	attr_reader :output_dir

	def initialize(file)

		raise "An output file must be provided" if file == nil
		
		@output = file.to_s
		# if the output path ends in a path separator, it is a directory
		if @output =~ /[\/\\]$/
			@output_dir = @output
		else
			# forward-slashes required for File methods
			@output = Path::forward @output
			@output_dir = File.dirname(@output)
			@output_file = File.basename(@output)
		end

		# create file task for output
		@task = ASRake::ExeTask.define_task self.output do
			self.execute
		end

		@task.pre_invoke = method(:task_pre_invoke)
		@task.post_invoke = method(:task_post_invoke)

		# create directory task for output
		if !self.output_is_dir?
			directory self.output_dir
			@task.enhance([self.output_dir])
		end
	end

	def output_is_dir?
		output_file == nil
	end

	def merge_in(args)
		@@args.each do |arg|
			# TODO: This needs to concat arrays not overwite them
			self.send("#{arg}=", args.send(arg))
		end
	end

	def to_s
		@output
	end

	def to_str
		@output
	end

	# used so we can add this task to a FileList. This is probably a terrible idea.
	def pathmap *args
		to_s.pathmap *args
	end

	def execute
		raise "Must define execute in subclass"
	end

	protected

	def task_pre_invoke
		# only run once to add prereqs
		@task.pre_invoke = nil
	end

	def task_post_invoke
		puts "#{Path::env self.output} (#{File.size(self.output)} bytes)" unless self.output_is_dir?
		# only run once incase invoked again
		@task.post_invoke = nil
	end

end
end