require 'rake/tasklib'

require 'asrake/host'
require 'asrake/base_compiler_task'
require 'asrake/compc_args'

module ASRake
class CompcTask < BaseCompilerTask
	include CompcArguments_Module

	# Create a swc compilation task with the given name.
	def initialize(name = :build, args = nil)
		super

		# create directory task for output
		directory self.output_dir

		# create file task for output
		file self.output => self.output_dir do
			self.build
		end

		# set dependencies on all .as and .mxml files in the source paths
		dependencies = FileList.new
		source_path.each do |path|
			path = cf path
			dependencies.include(File.join(path, "*.as"))
			dependencies.include(File.join(path, "*.mxml"))
			dependencies.include(File.join(path, "**", "*.as"))
			dependencies.include(File.join(path, "**", "*.mxml"))
		end
		file(self.output => dependencies) if !dependencies.empty?

		# add output file task as a dependency to the named task created
		task @name => self.output do
			result = c self.output
			result << " (#{File.size(output)} bytes)" unless self.output_is_dir?
			puts result
		end

	end

	protected

	def build
		run "#{FlexSDK::compc}#{generate_args}" do |line|
			generate_error_message_tips(line)
		end
	end

end
end