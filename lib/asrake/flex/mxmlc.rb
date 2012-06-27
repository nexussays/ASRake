require 'asrake/flex/flexsdk'
require 'asrake/flex/compiler_args'

module ASRake

module MxmlcArguments
	include BaseCompilerArguments
end

class Mxmlc
	include MxmlcArguments
end

end