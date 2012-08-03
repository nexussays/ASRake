require 'asrake/flexsdk'
require 'asrake/base_compiler_args'

module ASRake

module CompcArguments_Module
	include BaseCompilerArguments_Module

	def compiler
		FlexSDK::compc
	end

	def generate_args
		compc = super
		
		#compc << " -include-sources=#{cf source_path.join(',')}" if !source_path.empty?
		self.source_path.each do |path|
			compc << " -include-classes #{get_classes(path).join(' ')}"
		end

		return compc
	end

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

class CompcArguments
	include CompcArguments_Module
end

end