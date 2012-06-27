require 'rake/tasklib'

require 'asrake/host'
require 'asrake/basecompilertask'
require 'asrake/flex/compc'

module ASRake
class SWCTask < BaseCompilerTask
	include CompcArguments

	# Create a swc compilation task with the given name.
	def initialize(name = :build, args = nil)
		super

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

	end

	protected

	def build
		run "#{FlexSDK::compc}#{generate_args}" do |line|
			generate_error_message_tips(line)
		end
	end

end
end