require 'asrake/base_task'
require 'asrake/flexsdk'
require 'nokogiri'

module ASRake
class BaseCompiler < BaseTask

	include ASRake::PathUtils
	include Rake::DSL
	
	#
	# compiler arguments
	#

	@@args = [
		:source_path,
		:library_path,
		:external_library_path,
		:include_libraries,

		:load_config,
		:target_player,
		:swf_version,

		:debug,

		:dump_config,

		:additional_args
	]
	attr_accessor *@@args

	def initialize(file, exe_path)
		@exe = exe_path

		@isAIR = false
		@library_path = []
		@external_library_path = []
		@include_libraries = []
		@source_path = []
		@debug = false
		#include default flex-config
		@load_config = [ FlexSDK::flex_config ]

		super(file)

		# allow setting source_path with '=' instead of '<<'
		# actually, no, this is really bad and confusing we should probably throw when they try to assign
		#self.source_path = [self.source_path] if self.source_path.is_a? String

	end

	# provide a more understandable alias 
	def statically_link_only_referenced_classes
		library_path
	end

	def statically_link
		include_libraries
	end

	def dynamically_link
		external_library_path
	end

	# use the air configs if true
	def isAIR
		@isAIR
	end
	def isAIR= value
		@isAIR = value
		# if the default config is in the load-config array, replace it with the proper one based on context
		if @isAIR
			self.load_config.map! {|val| val == FlexSDK::flex_config ? FlexSDK::air_config : val}
		else
			self.load_config.map! {|val| val == FlexSDK::air_config ? FlexSDK::flex_config : val}
		end
	end
	# alias them as well
	alias_method :isAir, :isAIR
	alias_method :isAir=, :isAIR=

	#
	# Verify properties and then return build arguments
	#
	def generate_args
		
		# TODO: have this be checked when assigned and throw on string so the user understands the proper syntax
		#self.source_path = [self.source_path] if self.source_path.is_a? String
		#self.load_config = [self.load_config] if self.load_config.is_a? String
		#self.library_path = [self.library_path] if self.library_path.is_a? String
		#self.external_library_path = [self.external_library_path] if self.external_library_path.is_a? String
		#self.include_libraries = [self.include_libraries] if self.include_libraries.is_a? String

		# set to true if the version is defined in one of the referenced configs
		is_target_defined = false
		if self.target_player == nil
			# try to find necessary args in any loaded config files
			unless self.load_config.length == 1 && is_default_config?(self.load_config[0])
				# load config in reverse so last added has priority
				self.load_config.reverse.each do |config|
					flex_config = Nokogiri::XML(File.read(config))
					
					is_target_defined = true if flex_config.at_css('target-player')
					#configSource? = true if 
				end
			end
		end

		fail "You must define 'target_player' for #{self}" if self.target_player == nil && !is_target_defined

		# TODO: iterate over all non-default config files provided and look for source-path entries
		#fail "You must add at least one path to 'source_path' for #{self}" if source_path.empty? && !configSource?

		# TODO: iterate over all non-default config files provided and look for output
		fail "You must define 'output' for #{self}" if self.output == nil

		#
		# validation complete, generate build args
		#

		args = ""
		# set output as directory if it ends in a trailing slash
		args << " -output=#{cf output}"
		args << " -directory=true" if output_is_dir?

		args << " -target-player=#{target_player}" if self.target_player != nil
		args << " -swf-version=#{swf_version}" if self.swf_version != nil

		args << " +configname=air" if self.isAIR

		args << " -debug=#{debug}"
		args << " -source-path=#{cf source_path.join(',')}" if !self.source_path.empty?

		# add the -load-config option if it is anything other than the default
		unless self.load_config.length == 1 && is_default_config?(self.load_config[0])
			# if the default flex config is still in the load_config array, then append all config files, otherwise have the first one replace
			op = has_default_config_file? ? "+=" : "="
			self.load_config.each do |config|
				args << " -load-config#{op}#{cf config}" unless is_default_config?(config)
				op = "+="
			end
		end

		args << " -library-path=#{cf library_path.join(',')}" if !self.library_path.empty?
		args << " -external-library-path=#{cf external_library_path.join(',')}" if !self.external_library_path.empty?
		args << " -include-libraries=#{cf include_libraries.join(',')}" if !self.include_libraries.empty?

		args << " -dump-config=#{cf dump_config}" if self.dump_config != nil
		
		args << " #{additional_args}" if self.additional_args != nil
		#args << ' -include-file images\core_logo.png ..\nexuslib\code\etc\core_logo.png'
		
		return args
	end

	def execute
		puts "> #{@exe}#{generate_args}"
		run "#{@exe}#{generate_args}" do |line|
			puts ">    #{line}"
			generate_error_message_tips(line)
		end
	end

	private

	def has_default_config_file?
		self.load_config.each do |path|
			return true if is_default_config? path
		end
		return false
	end

	def is_default_config?(path)
		return (path == FlexSDK::flex_config || path == FlexSDK::air_config)
	end

	# Try to include helpful information about specific errors
	def generate_error_message_tips(line)
		advice = []
		if((target_player == nil || Float(target_player) < 11) && line.include?("Error: Access of undefined property JSON"))
			advice << "Be sure you are compiling with 'target_player' set to 11.0 or higher"
			advice << "to have access to the native JSON parser. It is currently set to #{target_player}"
		elsif line.include?("Error: The definition of base class Object was not found")
			advice << "If you have removed the default flex-config by setting 'load_config' to"
			advice << "an empty or alternate value using = instead of << you must be sure to"
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

#-dump-config compiler_config.xml
#-link-report compiler_linkreport.xml
#-size-report compiler_sizereport.xml