require 'asrake/flex/flexsdk'
require 'asrake/flex/compiler_args'

module ASRake

	module CompcArguments
		include BaseCompilerArguments

		def command
			compc = super
			
			#compc << " -include-sources=#{cf source_path.join(',')}" if !source_path.empty?
			source_path.each do |path|
				compc << " -include-classes #{get_classes(path).join(' ')}"
			end

			return compc
		end
	end

	class Compc
		include CompcArguments
	end

end