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
		if !output_is_dir?
			directory self.output_dir
			file self.output => self.output_dir
		end
		
		# create file task for output
		file self.output do
			self.build
		end

		# allow setting source_path with '=' instead of '<<'
		self.source_path = [self.source_path] if self.source_path.is_a? String

		# set dependencies on all .as and .mxml files in the source paths
		dependencies = FileList.new
		self.source_path.each do |path|
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

end
end