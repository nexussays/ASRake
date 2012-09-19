require 'asrake/flexsdk'
require 'asrake/base_compiler_args'

module ASRake

module CompcArguments_Module
	include BaseCompilerArguments_Module

	attr_accessor :include_asdoc
	
	def compiler
		FlexSDK::compc
	end

	def generate_args
		compc = super
		
		#compc << " -include-sources=#{cf source_path.join(',')}" if !source_path.empty?
		self.source_path.each do |path|
			compc << " -include-classes #{ASRake::get_classes(path).join(' ')}"
		end

		return compc
	end

	def merge_in(args)
		super
		self.include_asdoc = args.include_asdoc
	end

end

class CompcArguments
	include CompcArguments_Module
end

end