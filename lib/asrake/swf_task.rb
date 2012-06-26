require 'rake/tasklib'

require 'asrake/host'
require 'asrake/mxmlc'
require 'asrake/basecompilertask'

module ASRake
class SWFTask < BaseCompilerTask
	include MxmlcArguments

	# Create a swc compilation task with the given name.
	def initialize(name = :build, args = nil, &block)
		super(name, args, FlexSDK::mxmlc_path, &block)

	end

end
end