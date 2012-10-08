require 'asrake/util'

module ASRake
class BaseTask

	include ASRake::PathUtils
	include Rake::DSL

	#
	# non-compiler arguments
	#
	
	attr_reader :output
	attr_reader :output_file
	attr_reader :output_dir

	def initialize(file=nil)

		raise "Output file/directory must be provided" if file == nil

		@output = file
		# if the output path ends in a path separator, it is a directory
		if @output =~ /[\/\\]$/
			@output_dir = @output
		else
			# forward-slashes required for File methods
			@output = cf @output
			@output_dir = File.dirname(@output)
			@output_file = File.basename(@output)
		end

		yield self if block_given?

		# create file task for output
		file self.output do
			self.execute
			# TODO: Want to output this even if the dependencies are met and the task isn't run
			result = c self.output
			result << " (#{File.size(output)} bytes)" unless self.output_is_dir?
			puts result
		end

		# create directory task for output
		if !output_is_dir?
			directory self.output_dir
			file self.output => self.output_dir
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

	def execute
		raise "Must define execute in subclass"
	end

end
end