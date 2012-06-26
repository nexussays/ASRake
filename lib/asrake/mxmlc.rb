require 'asrake/flexsdk'
require 'asrake/base_args'

module ASRake

	module MxmlcArguments
		include BaseCompilerArguments

		attr_accessor :isAIR

		def command
			compc = super
			
			compc << " +configname=air" if isAIR

			return compc
		end
	end

	class Mxmlc
		include MxmlcArguments
	end

end