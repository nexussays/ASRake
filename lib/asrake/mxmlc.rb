require 'asrake/util'
require 'asrake/base_compiler'
require 'asrake/asdoc'

module ASRake
class Mxmlc < BaseCompiler

	include ASRake::PathUtils
	include Rake::DSL
	
	def initialize(swf_file)
		super(swf_file, FlexSDK::mxmlc)
	end

end
end