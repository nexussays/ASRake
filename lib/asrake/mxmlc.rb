require 'asrake/util'
require 'asrake/base_compiler'
require 'asrake/asdoc'

module ASRake
class Mxmlc < BaseCompiler

	include ASRake::PathUtils
	include Rake::DSL
	
	# Create a swc compilation task with the given name.
	def initialize(name = :build, args = nil)
		super(file, FlexSDK::mxmlc)
	end

end
end