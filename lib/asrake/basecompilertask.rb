require 'rake/tasklib'

require 'asrake/flex/compiler_args'

module ASRake
class BaseCompilerTask < Rake::TaskLib
	include BaseCompilerArguments

	def initialize(name, args)
		super()
		@name = name
		self.merge_in args if args != nil

		yield self if block_given?
		#block.call(self) if block != nil

		# create named task first so it gets the desc if one is added
		Rake::Task.define_task @name do
			result = c self.output
			result << " (#{File.size(output)} bytes)" unless self.output_is_dir?
			puts result
		end

		# if the task name is a hash (ie, has dependencies defined) make sure we pull out the task name from it
		@name, _ = name.first if name.is_a? Hash

		# create directory task for output
		directory self.output_dir

		# create file task for output
		file self.output => self.output_dir

		# add output file task as a dependency to the named task created
		task @name => self.output
		
		# create the task to compile the swc
		file self.output do
			self.build
		end

	end

	protected

	def build
		fail "build must be defined in subclass"
	end

	private

	# Try to include helpful information about specific errors
	def generate_error_message_tips(line)
		advice = []
		if((target_player == nil || Float(target_player) < 11) && line.include?("Error: Access of undefined property JSON"))
			advice << "Be sure you are compiling with 'target_player' set to 11.0 or higher"
			advice << "to have access to the native JSON parser. It is currently set to #{target_player}"
		elsif line.include?("Error: The definition of base class Object was not found")
			advice << "If you have removed the default flex-config by setting 'load_config' to"
			advice << "an empty or alternate value (i.e., not appended to it) you must be sure to"
			advice << "still reference the necessary core Flash files, especially playerglobal.swc"
		end

		if !advice.empty?
			puts "*********************************"
			puts "ASRake Note: " + advice.join("\n")
			puts "*********************************"
		end
	end

end
end

##fill config with the default flex_config options
#if use_default_flex_config
#	#initialize with default values from flex-config
#	flex_config = Nokogiri::XML(File.read(FlexSDK::flex_config))
#
#	target_player = flex_config.css('target-player').children.to_s
#	swf_version = flex_config.css('swf-version').children.to_s
#	
#	flex_config.css('compiler external-library-path path-element').each { |ext|
#		puts ext.children
#	}
#end

#http://fpdownload.macromedia.com/get/flashplayer/updaters/11/playerglobal11_2.swc
#frameworks\libs\player

#-dump-config compiler_config.xml
#-link-report compiler_linkreport.xml
#-size-report compiler_sizereport.xml