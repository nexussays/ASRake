require 'asrake/flexsdk'
require 'asrake/base_compiler_args'

module ASRake

module MxmlcArguments_Module
	include BaseCompilerArguments_Module

	def compiler
		FlexSDK::mxmlc
	end
end

class MxmlcArguments
	include MxmlcArguments_Module
end

end