require 'rake/tasklib'

require 'asrake/host'
require 'asrake/basecompilertask'
require 'asrake/flex/compc'

module ASRake
class SWCTask < BaseCompilerTask
	include CompcArguments

	# Create a swc compilation task with the given name.
	def initialize(name = :build, args = nil, &block)
		super(name, args, FlexSDK::compc, &block)

		# set dependencies on all .as and .mxml files in the source paths
		dependencies = FileList.new
		source_path.each do |path|
			path = cf path
			dependencies.include(File.join(path, "*.as"))
			dependencies.include(File.join(path, "*.mxml"))
			dependencies.include(File.join(path, "**", "*.as"))
			dependencies.include(File.join(path, "**", "*.mxml"))
		end
		file(output => dependencies) if !dependencies.empty?

	end

	private

	def get_classes(path)
		arr = []
		Dir.chdir(path) do
			FileList["**/*.as"].pathmap('%X').each do |file|
				name = file.gsub(/^\.[\/\\]/, "").gsub(/[\/\\]/, ".")
				yield name if block_given?
				arr << name
			end
		end
		return arr
	end

end
end