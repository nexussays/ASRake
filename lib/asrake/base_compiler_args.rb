require 'asrake/flexsdk'
require 'nokogiri'

module ASRake

module BaseCompilerArguments_Module

	#
	# compiler arguments
	#

	@@args = [
		:output,

		:source_path,
		:library_path,
		:external_library_path,
		:include_libraries,

		:load_config,
		:target_player,
		:swf_version,

		:debug,

		:dump_config
	]
	attr_accessor *@@args

	attr_accessor :additional_args

	#
	# non-compiler arguments
	#
	
	attr_reader :output_file
	attr_reader :output_dir

	def initialize
		super
		@isAIR = false
		@library_path = []
		@external_library_path = []
		@include_libraries = []
		@source_path = []
		@debug = false
		#include default flex-config
		@load_config = [ FlexSDK::flex_config ]
	end

	def output
		@output
	end

	def output= value
		@output = value
		# if the output path ends in a path separator, it is a directory
		if @output =~ /[\/\\]$/
			@output_dir = @output
		else
			# forward-slashes required for File methods
			@output = cf @output
			@output_dir = File.dirname(@output)
			@output_file = File.basename(@output)
		end
	end

	def output_is_dir?
		output_file == nil
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
		# if the default config is in the load-config array, replace it with the proper one
		if @isAIR
			self.load_config.map! {|val| val == FlexSDK::flex_config ? FlexSDK::air_config : val}
		else
			self.load_config.map! {|val| val == FlexSDK::air_config ? FlexSDK::flex_config : val}
		end
	end

	def merge_in(args)
		@@args.each do |arg|
			# TODO: This needs to concat arrays not overwite them
			self.send("#{arg}=", args.send(arg))
		end
	end

	def to_s
		generate_args
	end

	#
	# Verify properties and then return build arguments
	#
	def generate_args
		
		# set to true if the version is defined in one of the referenced configs
		isTargetDefined = false
		if self.target_player == nil
			# try to find necessary args in any loaded config files
			unless self.load_config.length == 1 && isDefaultConfig?(self.load_config[0])
				# load config in reverse so last added has priority
				self.load_config.reverse.each do |config|
					flex_config = Nokogiri::XML(File.read(config))
					
					isTargetDefined = true if flex_config.at_css('target-player')
					#configSource? = true if 
				end
			end
		end

		fail "You must define 'target_player' for #{self}" if self.target_player == nil && !isTargetDefined

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
		unless self.load_config.length == 1 && isDefaultConfig?(self.load_config[0])
			# if the default flex config is still in the load_config array, then append all config files, otherwise have the first one replace
			op = hasDefaultConfigFile? ? "+=" : "="
			self.load_config.each do |config|
				args << " -load-config#{op}#{cf config}" unless isDefaultConfig?(config)
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

	private

	def hasDefaultConfigFile?
		self.load_config.each do |path|
			return true if isDefaultConfig? path
		end
		return false
	end

	def isDefaultConfig?(path)
		return (path == FlexSDK::flex_config || path == FlexSDK::air_config)
	end

end
end