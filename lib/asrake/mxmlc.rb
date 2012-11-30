require 'asrake/util'
require 'asrake/base_compiler'
require 'asrake/asdoc'

module ASRake
class Mxmlc < BaseCompiler

	include Rake::DSL

	attr_accessor :file_specs
	
	def initialize(swf_file)
		super(swf_file, FlexSDK::mxmlc)
	end

	def generate_args
		mxmlc = super
		
		mxmlc << " -file-specs=#{file_specs}" if file_specs != nil

		return mxmlc
	end

	protected

	def handle_execute_error code
		case code
		when 1
			raise "A target file can be specified by setting file_specs to a valid .as or .mxml file.\n" +
				"eg:\n" +
				"  swf = ASRake::Mxmlc.new #{output}\n" +
				"  swf.file_specs = 'src/Main.as'" if file_specs == nil
		end
	end

end
end